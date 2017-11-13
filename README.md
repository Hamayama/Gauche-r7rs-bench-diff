# Gauche-r7rs-bench-diff

## 概要
- R7RS Benchmarks を Gauche で実行するための変更をまとめたものです。  
  使用する R7RS Benchmarks のページは以下になります。  
  https://github.com/ecraven/r7rs-benchmarks  
  (実行結果 https://ecraven.github.io/r7rs-benchmarks/benchmark.html )

- 実行には、上記ページのファイル一式と、実行のための開発環境が必要です。


## 変更点
1. dynamic の実行でエラーになる件  
   
   **◎本件は、Gauche v0.9.5 では、環境変数 GAUCHE_KEYWORD_IS_SYMBOL を  
   設定することで回避可能です。  
   このため (symbol? ':key1) が #f になる場合のみ、以下の対策を行うように  
   変更しました。(2016-7-30)**  
   
   dynamic-parse-datum という手続きで、Gauche の キーワード型 (:key1 等) を  
   認識できずにエラーとなっていた。  
   対策として、Gauche-prelude.scm で symbol? を上書きして、  
   キーワード型の場合も #t を返すようにした。  
   (Gauche-prelude.scm は、各ベンチマークの先頭に付加されて実行されるファイル)

2. gcbench の実行でエラーになる件  
   
   **◎本件は、Gauche v0.9.5 では、修正されています。  
   このため、Gauche のバージョンが 0.9.4 以下の場合のみ、以下の対策を行うように  
   変更しました。(2016-7-30)**  
   
   トップレベルではなく 手続きの内部で、define-record-type を使用している  
   ところがあり、そこで以下のエラーが発生していた。  
   `*** ERROR: syntax-error: the form can appear only in the toplevel`  
   Gauche の組み込みのレコードは、トップレベルでのみ定義可能なもよう。  
   
   対策として、SRFI-9 の参照実装の define-record-type を、  
   srfi-9-mod.scm という Gauche 用のモジュールにして、  
   Gauche-prelude.scm でそれを読み込んで使用するようにした。  
   (Gauche-prelude.scm は、各ベンチマークの先頭に付加されて実行されるファイル)  
   
   ( このとき、R7RS ライブラリ化した srfi-9-lib.scm も作成してみたが、  
   読み込むと、以下の同じエラーが発生した。  
   `*** ERROR: syntax-error: the form can appear only in the toplevel`  
   define-library だと何か仕組みが違うのか。。。)  
   
   (別の修正方法として、define-record-type をトップレベルに移動することでも、  
   エラーを回避できる。  
   こうすると、srfi-9-mod.scm を使う場合にくらべて 5 倍以上高速になるもよう。  
   (233(sec) → 35(sec))  
   しかし、ベンチマークプログラムの本体を変更するのはよくないと考えて、  
   やはり srfi-9-mod.scm を使うようにした)

3. メモリ不足で実行できない件  
   array1, mperm, paraffins が、4GB の RAM では、うまく実行できなかった。  
   (エラーにはならないが、PCが反応しない状態になった)  
   対策として、inputs フォルダの array1.input, mperm.input, paraffins.input を修正して、  
   使用メモリ量を減らした。  
   
   ```
   array1:1000000:500 → array1:100000:500
   mperm:20:10:2:1 → mperm:10:9:2:1
   paraffins:23:10 → mperm:23:1
   ```

4. Gauche-postlude.scm の変更  
   slib の scheme-implementation-version 手続きを使うのをやめて、替わりに  
   gauche.base の gauche-version 手続きを使うようにした。  
   (Gauche-postlude.scm は、各ベンチマークの末尾に付加されて実行されるファイル)


## 実行方法
1. 事前準備  
   事前に開発環境がインストールされている必要があります。  
   Windows の場合には、MSYS2/MinGW-w64 (64bit/32bit) の開発環境が必要です。  
   以下のページを参考にインストールを実施ください。  
   https://gist.github.com/Hamayama/eb4b4824ada3ac71beee0c9bb5fa546d  
   (すでにインストール済みであれば本手順は不要です)

2. R7RS Benchmarks のファイルのダウンロード  
   R7RS Benchmarks のページ  
   https://github.com/ecraven/r7rs-benchmarks  
   から、ベンチマークのファイル一式を、  
   (Download Zip ボタン等で)ダウンロードして、適当なフォルダに展開してください。

3. 本サイトのファイルのダウンロード  
   本サイト( https://github.com/Hamayama/Gauche-r7rs-bench-diff )のファイル一式を、  
   (Download Zip ボタン等で)ダウンロードして、適当なフォルダに展開してください。

4. ファイルのコピー  
   本サイトのファイルの Gauche-prelude.scm と Gauche-postlude.scm を、  
   R7RS Benchmarks の src フォルダに上書きコピーしてください。  
   
   また、本サイトのファイルの array1.input, mperm.input, paraffins.input を  
   R7RS Benchmarks の inputs フォルダに上書きコピーしてください。  
   
   また、本サイトのファイルの srfi-9-mod.scm を、  
   Gauche でロード可能なフォルダにコピーしてください。  
   (例えば (gauche-site-library-directory) で表示されるフォルダ等)  
   (ベンチマークのプログラムがテンポラリフォルダ内で実行されるため、  
   このファイルのロードには、相対パス指定が使えませんでした)

5. ベンチマークの実行  
   シェルからコマンドを実行します。  
   ＜MSYS2/MinGW-w64 (64bit) 環境の場合＞  
   プログラムメニューから MSYS2 の MinGW-w64 Win64 Shell を起動して、以下のコマンドを実行してください。  
   ＜MSYS2/MinGW-w64 (32bit) 環境の場合＞  
   プログラムメニューから MSYS2 の MinGW-w64 Win32 Shell を起動して、以下のコマンドを実行してください。  
   ( c:\work にベンチマークのファイルを展開した場合)  
   
   ```
   cd /c/work/r7rs-benchmarks
   make gauche
   ```
   実行が完了するまでには、かなり時間がかかります。  
   完了すると、r7rs-benchmarks フォルダに results.Gauche というファイルができています。  
   ここで、以下のコマンドを実行すると、all.csv という結果をまとめたファイルが生成されます。  
   
   ```
   make csv
   ```
   
   (注意)  
   results.Gauche には前回の結果が消されずに追記されていきます。  
   このため、複数回実行する場合には、必要に応じて、このファイルを削除するかリネームしてから  
   実行してください。  
   
   (注意)  
   Windows では ulimit -t でCPU時間を制限できないため、エラーメッセージが表示されます。  
   (実行は問題なく継続されます)  
   
   (注意)  
   個別のベンチマークを実行する場合には、上記の make gauche の替わりに  
   ```
   ./bench gauche tak  
   ```
   のように入力してください (tak の部分にはベンチマークの名前を入れます)。


## 実行結果(参考)
- 以下は、自分のPCで実行した結果です。  
  Gauche の v0.9.5 と v0.9.4 で測定しました。  
  https://drive.google.com/open?id=126pkkpUMz8XQPopTDe3UJdJ4-yor9cu8WzpEBFM50LI  
  PC : Intel(R) Core(TM) i3-5005U CPU @ 2.00GHz with 4GB of RAM.  
  OS : Windows 8.1 (64bit)  
  環境 : MSYS2/MinGW-w64 (64bit)  
  array1:1000000:500 → array1:100000:500 (メモリ不足のため)  
  mperm:20:10:2:1 → mperm:10:9:2:1 (メモリ不足のため)  
  paraffins:23:10 → paraffins:23:1 (メモリ不足のため)  
  
- 下記のページと比べると、全体的に2倍くらい遅くなっていますが、  
  CPU, メモリ量, OS等の違いかと思います。  
  https://ecraven.github.io/r7rs-benchmarks/benchmark.html


## 環境等
- OS
  - Windows 8.1 (64bit)
- 環境
  - MSYS2/MinGW-w64 (64bit/32bit)
- 言語
  - Gauche v0.9.6_pre4
  - Gauche v0.9.5
  - Gauche v0.9.4

## 履歴
- 2016-7-29  v1.00 (初版)
- 2016-7-30  v1.01 Gaucheのバージョンアップに対応
- 2016-10-13 v1.02 README修正のみ(Gauche v0.9.5 対応)
- 2017-11-13 v1.03 paraffins.inputを変更(メモリ不足対策)


(2017-11-13)
