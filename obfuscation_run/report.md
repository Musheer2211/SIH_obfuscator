# 🛡️ LLVM Obfuscation Build Report

**Date:** Sat Oct  4 07:32:03 UTC 2025

## Linux Transformation Log
```
==== SimpleObfPass Transformation Log ====
Running on module: obfuscation_run/linux/test.linux.ll

-> Created/found helper function: '__opaque_true'
-> Created/found global sink: '__obf_sink'

  [Entry] Modifying entry of function: main
    - Split entry block '' into '.entry.cont'
    - Added bogus code blocks: 'bogus.true' and 'bogus.false'
    - Replaced original terminator with opaque conditional branch.
  [Block] Modifying basic block: '.entry.cont' in function 'main'
    - Split block '.entry.cont' into '.entry.cont.cont2'
    - Added bogus code blocks: 'blk.alt1' and 'blk.alt2'
    - Replaced original terminator with opaque conditional branch.

==== Log End ====
```

## Windows Transformation Log
```
==== SimpleObfPass Transformation Log ====
Running on module: obfuscation_run/windows/test.windows.ll

-> Created/found helper function: '__opaque_true'
-> Created/found global sink: '__obf_sink'

  [Entry] Modifying entry of function: main
    - Split entry block '' into '.entry.cont'
    - Added bogus code blocks: 'bogus.true' and 'bogus.false'
    - Replaced original terminator with opaque conditional branch.
  [Block] Modifying basic block: '.entry.cont' in function 'main'
    - Split block '.entry.cont' into '.entry.cont.cont2'
    - Added bogus code blocks: 'blk.alt1' and 'blk.alt2'
    - Replaced original terminator with opaque conditional branch.
  [Entry] Modifying entry of function: scanf
    - Split entry block '' into '.entry.cont'
    - Added bogus code blocks: 'bogus.true' and 'bogus.false'
    - Replaced original terminator with opaque conditional branch.
  [Block] Modifying basic block: '.entry.cont' in function 'scanf'
    - Split block '.entry.cont' into '.entry.cont.cont2'
    - Added bogus code blocks: 'blk.alt1' and 'blk.alt2'
    - Replaced original terminator with opaque conditional branch.
  [Entry] Modifying entry of function: printf
    - Split entry block '' into '.entry.cont'
    - Added bogus code blocks: 'bogus.true' and 'bogus.false'
    - Replaced original terminator with opaque conditional branch.
  [Block] Modifying basic block: '.entry.cont' in function 'printf'
    - Split block '.entry.cont' into '.entry.cont.cont2'
    - Added bogus code blocks: 'blk.alt1' and 'blk.alt2'
    - Replaced original terminator with opaque conditional branch.

==== Log End ====
```

## Diff (Linux IR)
```diff
--- obfuscation_run/linux/test.linux.ll	2025-10-04 07:32:00.839016400 +0000
+++ obfuscation_run/linux/test.linux.obf.ll	2025-10-04 07:32:00.925663100 +0000
@@ -1,4 +1,4 @@
-; ModuleID = '../test.c'
+; ModuleID = 'obfuscation_run/linux/test.linux.ll'
 source_filename = "../test.c"
 target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
 target triple = "x86_64-pc-linux-gnu"
@@ -6,29 +6,54 @@
 @.str = private unnamed_addr constant [3 x i8] c"%s\00", align 1, !dbg !0
 @.str.1 = private unnamed_addr constant [5 x i8] c"test\00", align 1, !dbg !7
 @.str.2 = private unnamed_addr constant [21 x i8] c"Secret code is 50011\00", align 1, !dbg !12
+@__obf_sink = global i32 0
 
 ; Function Attrs: noinline nounwind optnone uwtable
 define dso_local i32 @main() #0 !dbg !27 {
-  %1 = alloca i32, align 4
-  %2 = alloca [100 x i8], align 16
-  store i32 0, ptr %1, align 4
-  call void @llvm.dbg.declare(metadata ptr %2, metadata !32, metadata !DIExpression()), !dbg !36
-  %3 = getelementptr inbounds [100 x i8], ptr %2, i64 0, i64 0, !dbg !37
-  %4 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef @.str, ptr noundef %3), !dbg !38
-  %5 = getelementptr inbounds [100 x i8], ptr %2, i64 0, i64 0, !dbg !39
-  %6 = call i32 @strcmp(ptr noundef %5, ptr noundef @.str.1) #4, !dbg !41
-  %7 = icmp eq i32 %6, 0, !dbg !42
-  br i1 %7, label %8, label %11, !dbg !43
-
-8:                                                ; preds = %0
-  %9 = call i32 (ptr, ...) @printf(ptr noundef @.str.2), !dbg !44
-  br label %10, !dbg !46
+  %1 = call i1 @__opaque_true()
+  br i1 %1, label %bogus.true, label %bogus.false
 
-10:                                               ; preds = %8, %10
-  br label %10, !dbg !46, !llvm.loop !47
+.entry.cont:                                      ; preds = %bogus.false, %bogus.true
+  %2 = alloca i32, align 4
+  %3 = alloca [100 x i8], align 16
+  store i32 0, ptr %2, align 4
+  call void @llvm.dbg.declare(metadata ptr %3, metadata !32, metadata !DIExpression()), !dbg !36
+  %4 = getelementptr inbounds [100 x i8], ptr %3, i64 0, i64 0, !dbg !37
+  %5 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef @.str, ptr noundef %4), !dbg !38
+  %6 = getelementptr inbounds [100 x i8], ptr %3, i64 0, i64 0, !dbg !39
+  %7 = call i32 @strcmp(ptr noundef %6, ptr noundef @.str.1) #5, !dbg !41
+  %8 = icmp eq i32 %7, 0, !dbg !42
+  %9 = call i1 @__opaque_true(), !dbg !43
+  br i1 %9, label %blk.alt1, label %blk.alt2
+
+.entry.cont.cont2:                                ; preds = %blk.alt2, %blk.alt1
+  br i1 %8, label %10, label %13, !dbg !43
+
+10:                                               ; preds = %.entry.cont.cont2
+  %11 = call i32 (ptr, ...) @printf(ptr noundef @.str.2), !dbg !44
+  br label %12, !dbg !46
 
-11:                                               ; preds = %0
+12:                                               ; preds = %12, %10
+  br label %12, !dbg !46, !llvm.loop !47
+
+13:                                               ; preds = %.entry.cont.cont2
   ret i32 0, !dbg !49
+
+bogus.true:                                       ; preds = %0
+  store volatile i32 26796, ptr @__obf_sink, align 4
+  br label %.entry.cont
+
+bogus.false:                                      ; preds = %0
+  store volatile i32 -2034231232, ptr @__obf_sink, align 4
+  br label %.entry.cont
+
+blk.alt1:                                         ; preds = %.entry.cont
+  store volatile i32 18, ptr @__obf_sink, align 4
+  br label %.entry.cont.cont2
+
+blk.alt2:                                         ; preds = %.entry.cont
+  store volatile i32 15, ptr @__obf_sink, align 4
+  br label %.entry.cont.cont2
 }
 
 ; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
@@ -41,11 +66,18 @@
 
 declare i32 @printf(ptr noundef, ...) #2
 
+; Function Attrs: noinline
+define i1 @__opaque_true() #4 {
+entry:
+  ret i1 true
+}
+
 attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
 attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
 attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
 attributes #3 = { nounwind willreturn memory(read) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
-attributes #4 = { nounwind willreturn memory(read) }
+attributes #4 = { noinline }
+attributes #5 = { nounwind willreturn memory(read) }
 
 !llvm.dbg.cu = !{!17}
 !llvm.module.flags = !{!19, !20, !21, !22, !23, !24, !25}
```

## Diff (Windows IR)
```diff
--- obfuscation_run/windows/test.windows.ll	2025-10-04 07:32:01.650140900 +0000
+++ obfuscation_run/windows/test.windows.obf.ll	2025-10-04 07:32:01.754386900 +0000
@@ -1,4 +1,4 @@
-; ModuleID = '../test.c'
+; ModuleID = 'obfuscation_run/windows/test.windows.ll'
 source_filename = "../test.c"
 target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
 target triple = "x86_64-w64-windows-gnu"
@@ -6,29 +6,54 @@
 @.str = private unnamed_addr constant [3 x i8] c"%s\00", align 1, !dbg !0
 @.str.1 = private unnamed_addr constant [5 x i8] c"test\00", align 1, !dbg !7
 @.str.2 = private unnamed_addr constant [21 x i8] c"Secret code is 50011\00", align 1, !dbg !12
+@__obf_sink = global i32 0
 
 ; Function Attrs: noinline nounwind optnone uwtable
 define dso_local i32 @main() #0 !dbg !26 {
-  %1 = alloca i32, align 4
-  %2 = alloca [100 x i8], align 16
-  store i32 0, ptr %1, align 4
-  call void @llvm.dbg.declare(metadata ptr %2, metadata !31, metadata !DIExpression()), !dbg !35
-  %3 = getelementptr inbounds [100 x i8], ptr %2, i64 0, i64 0, !dbg !36
-  %4 = call i32 (ptr, ...) @scanf(ptr noundef @.str, ptr noundef %3), !dbg !37
-  %5 = getelementptr inbounds [100 x i8], ptr %2, i64 0, i64 0, !dbg !38
-  %6 = call i32 @strcmp(ptr noundef %5, ptr noundef @.str.1), !dbg !40
-  %7 = icmp eq i32 %6, 0, !dbg !41
-  br i1 %7, label %8, label %11, !dbg !42
-
-8:                                                ; preds = %0
-  %9 = call i32 (ptr, ...) @printf(ptr noundef @.str.2), !dbg !43
-  br label %10, !dbg !45
+  %1 = call i1 @__opaque_true()
+  br i1 %1, label %bogus.true, label %bogus.false
 
-10:                                               ; preds = %8, %10
-  br label %10, !dbg !45, !llvm.loop !46
+.entry.cont:                                      ; preds = %bogus.false, %bogus.true
+  %2 = alloca i32, align 4
+  %3 = alloca [100 x i8], align 16
+  store i32 0, ptr %2, align 4
+  call void @llvm.dbg.declare(metadata ptr %3, metadata !31, metadata !DIExpression()), !dbg !35
+  %4 = getelementptr inbounds [100 x i8], ptr %3, i64 0, i64 0, !dbg !36
+  %5 = call i32 (ptr, ...) @scanf(ptr noundef @.str, ptr noundef %4), !dbg !37
+  %6 = getelementptr inbounds [100 x i8], ptr %3, i64 0, i64 0, !dbg !38
+  %7 = call i32 @strcmp(ptr noundef %6, ptr noundef @.str.1), !dbg !40
+  %8 = icmp eq i32 %7, 0, !dbg !41
+  %9 = call i1 @__opaque_true(), !dbg !42
+  br i1 %9, label %blk.alt1, label %blk.alt2
+
+.entry.cont.cont2:                                ; preds = %blk.alt2, %blk.alt1
+  br i1 %8, label %10, label %13, !dbg !42
+
+10:                                               ; preds = %.entry.cont.cont2
+  %11 = call i32 (ptr, ...) @printf(ptr noundef @.str.2), !dbg !43
+  br label %12, !dbg !45
 
-11:                                               ; preds = %0
+12:                                               ; preds = %12, %10
+  br label %12, !dbg !45, !llvm.loop !46
+
+13:                                               ; preds = %.entry.cont.cont2
   ret i32 0, !dbg !48
+
+bogus.true:                                       ; preds = %0
+  store volatile i32 26796, ptr @__obf_sink, align 4
+  br label %.entry.cont
+
+bogus.false:                                      ; preds = %0
+  store volatile i32 -2034231232, ptr @__obf_sink, align 4
+  br label %.entry.cont
+
+blk.alt1:                                         ; preds = %.entry.cont
+  store volatile i32 18, ptr @__obf_sink, align 4
+  br label %.entry.cont.cont2
+
+blk.alt2:                                         ; preds = %.entry.cont
+  store volatile i32 15, ptr @__obf_sink, align 4
+  br label %.entry.cont.cont2
 }
 
 ; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
@@ -36,44 +61,92 @@
 
 ; Function Attrs: noinline nounwind optnone uwtable
 define internal i32 @scanf(ptr noundef nonnull %0, ...) #0 !dbg !49 {
-  %2 = alloca ptr, align 8
-  %3 = alloca i32, align 4
-  %4 = alloca ptr, align 8
-  store ptr %0, ptr %2, align 8
-  call void @llvm.dbg.declare(metadata ptr %2, metadata !55, metadata !DIExpression()), !dbg !56
-  call void @llvm.dbg.declare(metadata ptr %3, metadata !57, metadata !DIExpression()), !dbg !58
-  call void @llvm.dbg.declare(metadata ptr %4, metadata !59, metadata !DIExpression()), !dbg !62
-  call void @llvm.va_start(ptr %4), !dbg !63
-  %5 = call ptr @__acrt_iob_func(i32 noundef 0), !dbg !64
-  %6 = load ptr, ptr %2, align 8, !dbg !65
-  %7 = load ptr, ptr %4, align 8, !dbg !66
-  %8 = call i32 @__mingw_vfscanf(ptr noundef %5, ptr noundef %6, ptr noundef %7), !dbg !67
-  store i32 %8, ptr %3, align 4, !dbg !68
-  call void @llvm.va_end(ptr %4), !dbg !69
-  %9 = load i32, ptr %3, align 4, !dbg !70
-  ret i32 %9, !dbg !71
+  %2 = call i1 @__opaque_true()
+  br i1 %2, label %bogus.true, label %bogus.false
+
+.entry.cont:                                      ; preds = %bogus.false, %bogus.true
+  %3 = alloca ptr, align 8
+  %4 = alloca i32, align 4
+  %5 = alloca ptr, align 8
+  store ptr %0, ptr %3, align 8
+  call void @llvm.dbg.declare(metadata ptr %3, metadata !55, metadata !DIExpression()), !dbg !56
+  call void @llvm.dbg.declare(metadata ptr %4, metadata !57, metadata !DIExpression()), !dbg !58
+  call void @llvm.dbg.declare(metadata ptr %5, metadata !59, metadata !DIExpression()), !dbg !62
+  call void @llvm.va_start(ptr %5), !dbg !63
+  %6 = call ptr @__acrt_iob_func(i32 noundef 0), !dbg !64
+  %7 = load ptr, ptr %3, align 8, !dbg !65
+  %8 = load ptr, ptr %5, align 8, !dbg !66
+  %9 = call i32 @__mingw_vfscanf(ptr noundef %6, ptr noundef %7, ptr noundef %8), !dbg !67
+  store i32 %9, ptr %4, align 4, !dbg !68
+  call void @llvm.va_end(ptr %5), !dbg !69
+  %10 = load i32, ptr %4, align 4, !dbg !70
+  %11 = call i1 @__opaque_true(), !dbg !71
+  br i1 %11, label %blk.alt1, label %blk.alt2
+
+.entry.cont.cont2:                                ; preds = %blk.alt2, %blk.alt1
+  ret i32 %10, !dbg !71
+
+bogus.true:                                       ; preds = %1
+  store volatile i32 26796, ptr @__obf_sink, align 4
+  br label %.entry.cont
+
+bogus.false:                                      ; preds = %1
+  store volatile i32 -2034231232, ptr @__obf_sink, align 4
+  br label %.entry.cont
+
+blk.alt1:                                         ; preds = %.entry.cont
+  store volatile i32 18, ptr @__obf_sink, align 4
+  br label %.entry.cont.cont2
+
+blk.alt2:                                         ; preds = %.entry.cont
+  store volatile i32 15, ptr @__obf_sink, align 4
+  br label %.entry.cont.cont2
 }
 
 declare dso_local i32 @strcmp(ptr noundef, ptr noundef) #2
 
 ; Function Attrs: noinline nounwind optnone uwtable
 define internal i32 @printf(ptr noundef nonnull %0, ...) #0 !dbg !72 {
-  %2 = alloca ptr, align 8
-  %3 = alloca i32, align 4
-  %4 = alloca ptr, align 8
-  store ptr %0, ptr %2, align 8
-  call void @llvm.dbg.declare(metadata ptr %2, metadata !73, metadata !DIExpression()), !dbg !74
-  call void @llvm.dbg.declare(metadata ptr %3, metadata !75, metadata !DIExpression()), !dbg !76
-  call void @llvm.dbg.declare(metadata ptr %4, metadata !77, metadata !DIExpression()), !dbg !78
-  call void @llvm.va_start(ptr %4), !dbg !79
-  %5 = call ptr @__acrt_iob_func(i32 noundef 1), !dbg !80
-  %6 = load ptr, ptr %2, align 8, !dbg !81
-  %7 = load ptr, ptr %4, align 8, !dbg !82
-  %8 = call i32 @__mingw_vfprintf(ptr noundef %5, ptr noundef %6, ptr noundef %7) #5, !dbg !83
-  store i32 %8, ptr %3, align 4, !dbg !84
-  call void @llvm.va_end(ptr %4), !dbg !85
-  %9 = load i32, ptr %3, align 4, !dbg !86
-  ret i32 %9, !dbg !87
+  %2 = call i1 @__opaque_true()
+  br i1 %2, label %bogus.true, label %bogus.false
+
+.entry.cont:                                      ; preds = %bogus.false, %bogus.true
+  %3 = alloca ptr, align 8
+  %4 = alloca i32, align 4
+  %5 = alloca ptr, align 8
+  store ptr %0, ptr %3, align 8
+  call void @llvm.dbg.declare(metadata ptr %3, metadata !73, metadata !DIExpression()), !dbg !74
+  call void @llvm.dbg.declare(metadata ptr %4, metadata !75, metadata !DIExpression()), !dbg !76
+  call void @llvm.dbg.declare(metadata ptr %5, metadata !77, metadata !DIExpression()), !dbg !78
+  call void @llvm.va_start(ptr %5), !dbg !79
+  %6 = call ptr @__acrt_iob_func(i32 noundef 1), !dbg !80
+  %7 = load ptr, ptr %3, align 8, !dbg !81
+  %8 = load ptr, ptr %5, align 8, !dbg !82
+  %9 = call i32 @__mingw_vfprintf(ptr noundef %6, ptr noundef %7, ptr noundef %8) #6, !dbg !83
+  store i32 %9, ptr %4, align 4, !dbg !84
+  call void @llvm.va_end(ptr %5), !dbg !85
+  %10 = load i32, ptr %4, align 4, !dbg !86
+  %11 = call i1 @__opaque_true(), !dbg !87
+  br i1 %11, label %blk.alt1, label %blk.alt2
+
+.entry.cont.cont2:                                ; preds = %blk.alt2, %blk.alt1
+  ret i32 %10, !dbg !87
+
+bogus.true:                                       ; preds = %1
+  store volatile i32 26796, ptr @__obf_sink, align 4
+  br label %.entry.cont
+
+bogus.false:                                      ; preds = %1
+  store volatile i32 -2034231232, ptr @__obf_sink, align 4
+  br label %.entry.cont
+
+blk.alt1:                                         ; preds = %.entry.cont
+  store volatile i32 18, ptr @__obf_sink, align 4
+  br label %.entry.cont.cont2
+
+blk.alt2:                                         ; preds = %.entry.cont
+  store volatile i32 15, ptr @__obf_sink, align 4
+  br label %.entry.cont.cont2
 }
 
 ; Function Attrs: nocallback nofree nosync nounwind willreturn
@@ -89,12 +162,19 @@
 ; Function Attrs: nounwind
 declare dso_local i32 @__mingw_vfprintf(ptr noundef, ptr noundef, ptr noundef) #4
 
+; Function Attrs: noinline
+define i1 @__opaque_true() #5 {
+entry:
+  ret i1 true
+}
+
 attributes #0 = { noinline nounwind optnone uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
 attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
 attributes #2 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
 attributes #3 = { nocallback nofree nosync nounwind willreturn }
 attributes #4 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
-attributes #5 = { nounwind }
+attributes #5 = { noinline }
+attributes #6 = { nounwind }
 
 !llvm.dbg.cu = !{!17}
 !llvm.module.flags = !{!19, !20, !21, !22, !23, !24}
```

## Artifacts
| Platform | Original | Obfuscated |
|----------|----------|------------|
| Linux    | obfuscation_run/linux/test.linux.original | obfuscation_run/linux/test.linux |
| Windows  | obfuscation_run/windows/test.windows.original.exe | obfuscation_run/windows/test.windows.exe |
