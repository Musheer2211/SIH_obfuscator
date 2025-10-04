; ModuleID = 'obfuscation_run/linux/test.linux.ll'
source_filename = "../test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%s\00", align 1, !dbg !0
@.str.1 = private unnamed_addr constant [5 x i8] c"test\00", align 1, !dbg !7
@.str.2 = private unnamed_addr constant [21 x i8] c"Secret code is 50011\00", align 1, !dbg !12
@__obf_sink = global i32 0

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 !dbg !27 {
  %1 = call i1 @__opaque_true()
  br i1 %1, label %bogus.true, label %bogus.false

.entry.cont:                                      ; preds = %bogus.false, %bogus.true
  %2 = alloca i32, align 4
  %3 = alloca [100 x i8], align 16
  store i32 0, ptr %2, align 4
  call void @llvm.dbg.declare(metadata ptr %3, metadata !32, metadata !DIExpression()), !dbg !36
  %4 = getelementptr inbounds [100 x i8], ptr %3, i64 0, i64 0, !dbg !37
  %5 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef @.str, ptr noundef %4), !dbg !38
  %6 = getelementptr inbounds [100 x i8], ptr %3, i64 0, i64 0, !dbg !39
  %7 = call i32 @strcmp(ptr noundef %6, ptr noundef @.str.1) #5, !dbg !41
  %8 = icmp eq i32 %7, 0, !dbg !42
  %9 = call i1 @__opaque_true(), !dbg !43
  br i1 %9, label %blk.alt1, label %blk.alt2

.entry.cont.cont2:                                ; preds = %blk.alt2, %blk.alt1
  br i1 %8, label %10, label %13, !dbg !43

10:                                               ; preds = %.entry.cont.cont2
  %11 = call i32 (ptr, ...) @printf(ptr noundef @.str.2), !dbg !44
  br label %12, !dbg !46

12:                                               ; preds = %12, %10
  br label %12, !dbg !46, !llvm.loop !47

13:                                               ; preds = %.entry.cont.cont2
  ret i32 0, !dbg !49

bogus.true:                                       ; preds = %0
  store volatile i32 26796, ptr @__obf_sink, align 4
  br label %.entry.cont

bogus.false:                                      ; preds = %0
  store volatile i32 -2034231232, ptr @__obf_sink, align 4
  br label %.entry.cont

blk.alt1:                                         ; preds = %.entry.cont
  store volatile i32 18, ptr @__obf_sink, align 4
  br label %.entry.cont.cont2

blk.alt2:                                         ; preds = %.entry.cont
  store volatile i32 15, ptr @__obf_sink, align 4
  br label %.entry.cont.cont2
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare i32 @__isoc99_scanf(ptr noundef, ...) #2

; Function Attrs: nounwind willreturn memory(read)
declare i32 @strcmp(ptr noundef, ptr noundef) #3

declare i32 @printf(ptr noundef, ...) #2

; Function Attrs: noinline
define i1 @__opaque_true() #4 {
entry:
  ret i1 true
}

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind willreturn memory(read) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { noinline }
attributes #5 = { nounwind willreturn memory(read) }

!llvm.dbg.cu = !{!17}
!llvm.module.flags = !{!19, !20, !21, !22, !23, !24, !25}
!llvm.ident = !{!26}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 6, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "../test.c", directory: "/mnt/c/Users/mushe/Desktop/Musheer_CS1/SIH/SimpleObfPass", checksumkind: CSK_MD5, checksum: "6f1ca53e18f5447d61ff310d31f92b3b")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 24, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 3)
!7 = !DIGlobalVariableExpression(var: !8, expr: !DIExpression())
!8 = distinct !DIGlobalVariable(scope: null, file: !2, line: 7, type: !9, isLocal: true, isDefinition: true)
!9 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 40, elements: !10)
!10 = !{!11}
!11 = !DISubrange(count: 5)
!12 = !DIGlobalVariableExpression(var: !13, expr: !DIExpression())
!13 = distinct !DIGlobalVariable(scope: null, file: !2, line: 9, type: !14, isLocal: true, isDefinition: true)
!14 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 168, elements: !15)
!15 = !{!16}
!16 = !DISubrange(count: 21)
!17 = distinct !DICompileUnit(language: DW_LANG_C11, file: !2, producer: "Ubuntu clang version 18.1.3 (1ubuntu1)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !18, splitDebugInlining: false, nameTableKind: None)
!18 = !{!0, !7, !12}
!19 = !{i32 7, !"Dwarf Version", i32 5}
!20 = !{i32 2, !"Debug Info Version", i32 3}
!21 = !{i32 1, !"wchar_size", i32 4}
!22 = !{i32 8, !"PIC Level", i32 2}
!23 = !{i32 7, !"PIE Level", i32 2}
!24 = !{i32 7, !"uwtable", i32 2}
!25 = !{i32 7, !"frame-pointer", i32 2}
!26 = !{!"Ubuntu clang version 18.1.3 (1ubuntu1)"}
!27 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 4, type: !28, scopeLine: 4, spFlags: DISPFlagDefinition, unit: !17, retainedNodes: !31)
!28 = !DISubroutineType(types: !29)
!29 = !{!30}
!30 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!31 = !{}
!32 = !DILocalVariable(name: "buffer", scope: !27, file: !2, line: 5, type: !33)
!33 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 800, elements: !34)
!34 = !{!35}
!35 = !DISubrange(count: 100)
!36 = !DILocation(line: 5, column: 10, scope: !27)
!37 = !DILocation(line: 6, column: 17, scope: !27)
!38 = !DILocation(line: 6, column: 5, scope: !27)
!39 = !DILocation(line: 7, column: 16, scope: !40)
!40 = distinct !DILexicalBlock(scope: !27, file: !2, line: 7, column: 9)
!41 = !DILocation(line: 7, column: 9, scope: !40)
!42 = !DILocation(line: 7, column: 31, scope: !40)
!43 = !DILocation(line: 7, column: 9, scope: !27)
!44 = !DILocation(line: 9, column: 9, scope: !45)
!45 = distinct !DILexicalBlock(scope: !40, file: !2, line: 8, column: 5)
!46 = !DILocation(line: 10, column: 9, scope: !45)
!47 = distinct !{!47, !46, !48}
!48 = !DILocation(line: 13, column: 9, scope: !45)
!49 = !DILocation(line: 17, column: 5, scope: !27)
