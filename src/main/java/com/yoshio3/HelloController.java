package com.yoshio3;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.UserPrincipal;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.stream.Stream;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    private final static int VERSION=1;

    @GetMapping("/hello")
    public String hello() {
        File dir = new File("/");
        listChildFiles(dir);

        showProcess();
        return "こんにちは、Hello World Version Tag: " + VERSION;
    }

    private void showProcess(){
        System.out.println("---------------- Process Lists --------------------");
        Stream<ProcessHandle> allProcesses = ProcessHandle.allProcesses();
        allProcesses.forEach(phandle -> {
            phandle.info().command().ifPresent(cmd -> {
                var pid = phandle.pid();
                var user = phandle.info().user().get();
                var startDateTime = ZonedDateTime.ofInstant(phandle.info().startInstant().get(), ZoneId.of("Asia/Tokyo"));
                var commandArgs = phandle.info().arguments().map(arg -> String.join(" ", arg)).orElse("");

                System.out.println(" PID" + "\tUser" + "\tStart Time" + "\tCommand"  + "\tArguments" );
                System.out.println("--------------------------------------------------------------------------------------------");
                System.out.println( pid + "\t" +  user + "\t" + startDateTime + "\t" + cmd + "\t" + commandArgs );
            });
        });
    }


    private void listChildFiles(File dir) {
        // listFilesメソッドを使用して一覧を取得する
        File[] lists = dir.listFiles();
        if (lists == null) {
            return;
        }
        for (File file : lists) {
            if (file.getName().equals("proc") || file.getName().equals("sys")) {
                continue;
            }
            String absolutePath = file.getAbsolutePath();
            if (file.isDirectory()) {
                System.out.print(" d");
                showFiles(file, absolutePath);
                File child = new File(absolutePath);
                listChildFiles(child);
            } else {
                System.out.print(" -");
                showFiles(file, absolutePath);
            }
        }
    }

    private void showFiles(File file, String absolutePath) {
        if (file.canRead()) {
            System.out.print("r");
        } else {
            System.out.print("-");
        }
        if (file.canWrite()) {
            System.out.print("w");
        } else {
            System.out.print("-");
        }
        if (file.canExecute()) {
            System.out.print("x");
        } else {
            System.out.print("-");
        }
        Path DirFile = Paths.get(absolutePath);
        try {
            System.out.print(" " + Files.size(DirFile));
            UserPrincipal owner = Files.getOwner(DirFile);
            System.out.print("\t\t" + owner.getName());
        } catch (IOException e) {
            System.out.print("  ");
        }
        System.out.println("\t\t" + absolutePath);
    }
}
