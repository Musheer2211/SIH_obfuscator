; ModuleID = 'obfuscation_run/windows/test.windows.ll'
source_filename = "../test.c"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-w64-windows-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%s\00", align 1, !dbg !0
@.str.1 = private unnamed_addr constant [5 x i8] c"test\00", align 1, !dbg !7
@.str.2 = private unnamed_addr constant [21 x i8] c"Secret code is 50011\00", align 1, !dbg !12
@__obf_sink = global i32 0

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 !dbg !26 {
  %1 = call i1 @__opaque_true()
  br i1 %1, label %bogus.true, label %bogus.false

.entry.cont:                                      ; preds = %bogus.false, %bogus.true
  %2 = alloca i32, align 4
  %3 = alloca [100 x i8], align 16
  store i32 0, ptr %2, align 4
  call void @llvm.dbg.declare(metadata ptr %3, metadata !31, metadata !DIExpression()), !dbg !35
  %4 = getelementptr inbounds [100 x i8], ptr %3, i64 0, i64 0, !dbg !36
  %5 = call i32 (ptr, ...) @scanf(ptr noundef @.str, ptr noundef %4), !dbg !37
  %6 = getelementptr inbounds [100 x i8], ptr %3, i64 0, i64 0, !dbg !38
  %7 = call i32 @strcmp(ptr noundef %6, ptr noundef @.str.1), !dbg !40
  %8 = icmp eq i32 %7, 0, !dbg !41
  %9 = call i1 @__opaque_true(), !dbg !42
  br i1 %9, label %blk.alt1, label %blk.alt2

.entry.cont.cont2:                                ; preds = %blk.alt2, %blk.alt1
  br i1 %8, label %10, label %13, !dbg !42

10:                                               ; preds = %.entry.cont.cont2
  %11 = call i32 (ptr, ...) @printf(ptr noundef @.str.2), !dbg !43
  br label %12, !dbg !45

12:                                               ; preds = %12, %10
  br label %12, !dbg !45, !llvm.loop !46

13:                                               ; preds = %.entry.cont.cont2
  ret i32 0, !dbg !48

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

; Function Attrs: noinline nounwind optnone uwtable
define internal i32 @scanf(ptr noundef nonnull %0, ...) #0 !dbg !49 {
  %2 = call i1 @__opaque_true()
  br i1 %2, label %bogus.true, label %bogus.false

.entry.cont:                                      ; preds = %bogus.false, %bogus.true
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  call void @llvm.dbg.declare(metadata ptr %3, metadata !55, metadata !DIExpression()), !dbg !56
  call void @llvm.dbg.declare(metadata ptr %4, metadata !57, metadata !DIExpression()), !dbg !58
  call void @llvm.dbg.declare(metadata ptr %5, metadata !59, metadata !DIExpression()), !dbg !62
  call void @llvm.va_start(ptr %5), !dbg !63
  %6 = call ptr @__acrt_iob_func(i32 noundef 0), !dbg !64
  %7 = load ptr, ptr %3, align 8, !dbg !65
  %8 = load ptr, ptr %5, align 8, !dbg !66
  %9 = call i32 @__mingw_vfscanf(ptr noundef %6, ptr noundef %7, ptr noundef %8), !dbg !67
  store i32 %9, ptr %4, align 4, !dbg !68
  call void @llvm.va_end(ptr %5), !dbg !69
  %10 = load i32, ptr %4, align 4, !dbg !70
  %11 = call i1 @__opaque_true(), !dbg !71
  br i1 %11, label %blk.alt1, label %blk.alt2

.entry.cont.cont2:                                ; preds = %blk.alt2, %blk.alt1
  ret i32 %10, !dbg !71

bogus.true:                                       ; preds = %1
  store volatile i32 26796, ptr @__obf_sink, align 4
  br label %.entry.cont

bogus.false:                                      ; preds = %1
  store volatile i32 -2034231232, ptr @__obf_sink, align 4
  br label %.entry.cont

blk.alt1:                                         ; preds = %.entry.cont
  store volatile i32 18, ptr @__obf_sink, align 4
  br label %.entry.cont.cont2

blk.alt2:                                         ; preds = %.entry.cont
  store volatile i32 15, ptr @__obf_sink, align 4
  br label %.entry.cont.cont2
}

declare dso_local i32 @strcmp(ptr noundef, ptr noundef) #2

; Function Attrs: noinline nounwind optnone uwtable
define internal i32 @printf(ptr noundef nonnull %0, ...) #0 !dbg !72 {
  %2 = call i1 @__opaque_true()
  br i1 %2, label %bogus.true, label %bogus.false

.entry.cont:                                      ; preds = %bogus.false, %bogus.true
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  call void @llvm.dbg.declare(metadata ptr %3, metadata !73, metadata !DIExpression()), !dbg !74
  call void @llvm.dbg.declare(metadata ptr %4, metadata !75, metadata !DIExpression()), !dbg !76
  call void @llvm.dbg.declare(metadata ptr %5, metadata !77, metadata !DIExpression()), !dbg !78
  call void @llvm.va_start(ptr %5), !dbg !79
  %6 = call ptr @__acrt_iob_func(i32 noundef 1), !dbg !80
  %7 = load ptr, ptr %3, align 8, !dbg !81
  %8 = load ptr, ptr %5, align 8, !dbg !82
  %9 = call i32 @__mingw_vfprintf(ptr noundef %6, ptr noundef %7, ptr noundef %8) #6, !dbg !83
  store i32 %9, ptr %4, align 4, !dbg !84
  call void @llvm.va_end(ptr %5), !dbg !85
  %10 = load i32, ptr %4, align 4, !dbg !86
  %11 = call i1 @__opaque_true(), !dbg !87
  br i1 %11, label %blk.alt1, label %blk.alt2

.entry.cont.cont2:                                ; preds = %blk.alt2, %blk.alt1
  ret i32 %10, !dbg !87

bogus.true:                                       ; preds = %1
  store volatile i32 26796, ptr @__obf_sink, align 4
  br label %.entry.cont

bogus.false:                                      ; preds = %1
  store volatile i32 -2034231232, ptr @__obf_sink, align 4
  br label %.entry.cont

blk.alt1:                                         ; preds = %.entry.cont
  store volatile i32 18, ptr @__obf_sink, align 4
  br label %.entry.cont.cont2

blk.alt2:                                         ; preds = %.entry.cont
  store volatile i32 15, ptr @__obf_sink, align 4
  br label %.entry.cont.cont2
}

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare void @llvm.va_start(ptr) #3

declare dso_local i32 @__mingw_vfscanf(ptr noundef, ptr noundef, ptr noundef) #2

declare dllimport ptr @__acrt_iob_func(i32 noundef) #2

; Function Attrs: nocallback nofree nosync nounwind willreturn
declare void @llvm.va_end(ptr) #3

; Function Attrs: nounwind
declare dso_local i32 @__mingw_vfprintf(ptr noundef, ptr noundef, ptr noundef) #4

; Function Attrs: noinline
define i1 @__opaque_true() #5 {
entry:
  ret i1 true
}

attributes #0 = { noinline nounwind optnone uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nocallback nofree nosync nounwind willreturn }
attributes #4 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { noinline }
attributes #6 = { nounwind }

!llvm.dbg.cu = !{!17}
!llvm.module.flags = !{!19, !20, !21, !22, !23, !24}
!llvm.ident = !{!25}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 6, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "../test.c", directory: "/mnt/c/Users/mushe/Desktop/Musheer_CS1/SIH/SimpleObfPass")
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
!19 = !{i32 7, !"Dwarf Version", i32 4}
!20 = !{i32 2, !"Debug Info Version", i32 3}
!21 = !{i32 1, !"wchar_size", i32 2}
!22 = !{i32 8, !"PIC Level", i32 2}
!23 = !{i32 7, !"uwtable", i32 2}
!24 = !{i32 1, !"MaxTLSAlign", i32 65536}
!25 = !{!"Ubuntu clang version 18.1.3 (1ubuntu1)"}
!26 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 4, type: !27, scopeLine: 4, spFlags: DISPFlagDefinition, unit: !17, retainedNodes: !30)
!27 = !DISubroutineType(types: !28)
!28 = !{!29}
!29 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!30 = !{}
!31 = !DILocalVariable(name: "buffer", scope: !26, file: !2, line: 5, type: !32)
!32 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 800, elements: !33)
!33 = !{!34}
!34 = !DISubrange(count: 100)
!35 = !DILocation(line: 5, column: 10, scope: !26)
!36 = !DILocation(line: 6, column: 17, scope: !26)
!37 = !DILocation(line: 6, column: 5, scope: !26)
!38 = !DILocation(line: 7, column: 16, scope: !39)
!39 = distinct !DILexicalBlock(scope: !26, file: !2, line: 7, column: 9)
!40 = !DILocation(line: 7, column: 9, scope: !39)
!41 = !DILocation(line: 7, column: 31, scope: !39)
!42 = !DILocation(line: 7, column: 9, scope: !26)
!43 = !DILocation(line: 9, column: 9, scope: !44)
!44 = distinct !DILexicalBlock(scope: !39, file: !2, line: 8, column: 5)
!45 = !DILocation(line: 10, column: 9, scope: !44)
!46 = distinct !{!46, !45, !47}
!47 = !DILocation(line: 13, column: 9, scope: !44)
!48 = !DILocation(line: 17, column: 5, scope: !26)
!49 = distinct !DISubprogram(name: "scanf", scope: !50, file: !50, line: 304, type: !51, scopeLine: 305, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !17, retainedNodes: !30)
!50 = !DIFile(filename: "/usr/x86_64-w64-mingw32/include/stdio.h", directory: "")
!51 = !DISubroutineType(types: !52)
!52 = !{!29, !53, null}
!53 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !54, size: 64)
!54 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !4)
!55 = !DILocalVariable(name: "__format", arg: 1, scope: !49, file: !50, line: 304, type: !53)
!56 = !DILocation(line: 304, column: 23, scope: !49)
!57 = !DILocalVariable(name: "__retval", scope: !49, file: !50, line: 306, type: !29)
!58 = !DILocation(line: 306, column: 7, scope: !49)
!59 = !DILocalVariable(name: "__local_argv", scope: !49, file: !50, line: 307, type: !60)
!60 = !DIDerivedType(tag: DW_TAG_typedef, name: "__builtin_va_list", file: !2, baseType: !61)
!61 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4, size: 64)
!62 = !DILocation(line: 307, column: 21, scope: !49)
!63 = !DILocation(line: 307, column: 35, scope: !49)
!64 = !DILocation(line: 308, column: 31, scope: !49)
!65 = !DILocation(line: 308, column: 38, scope: !49)
!66 = !DILocation(line: 308, column: 48, scope: !49)
!67 = !DILocation(line: 308, column: 14, scope: !49)
!68 = !DILocation(line: 308, column: 12, scope: !49)
!69 = !DILocation(line: 309, column: 3, scope: !49)
!70 = !DILocation(line: 310, column: 10, scope: !49)
!71 = !DILocation(line: 310, column: 3, scope: !49)
!72 = distinct !DISubprogram(name: "printf", scope: !50, file: !50, line: 371, type: !51, scopeLine: 372, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !17, retainedNodes: !30)
!73 = !DILocalVariable(name: "__format", arg: 1, scope: !72, file: !50, line: 371, type: !53)
!74 = !DILocation(line: 371, column: 25, scope: !72)
!75 = !DILocalVariable(name: "__retval", scope: !72, file: !50, line: 373, type: !29)
!76 = !DILocation(line: 373, column: 7, scope: !72)
!77 = !DILocalVariable(name: "__local_argv", scope: !72, file: !50, line: 374, type: !60)
!78 = !DILocation(line: 374, column: 21, scope: !72)
!79 = !DILocation(line: 374, column: 35, scope: !72)
!80 = !DILocation(line: 375, column: 32, scope: !72)
!81 = !DILocation(line: 375, column: 40, scope: !72)
!82 = !DILocation(line: 375, column: 50, scope: !72)
!83 = !DILocation(line: 375, column: 14, scope: !72)
!84 = !DILocation(line: 375, column: 12, scope: !72)
!85 = !DILocation(line: 376, column: 3, scope: !72)
!86 = !DILocation(line: 377, column: 10, scope: !72)
!87 = !DILocation(line: 377, column: 3, scope: !72)
