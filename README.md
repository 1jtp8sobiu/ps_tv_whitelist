# PS TV (Vita TV) Whitelist
Vitaのゲームソフトの中には、Vita TVでは起動が出来ないように制限のかけられたものが数多く存在します。
その起動制限を解除するための方法として「Whitelist化」と呼ばれる手法が存在しますが、手順がやや煩雑なものでした。

このツールを利用することでPC上での作業を全て自動化することができます。また旧来のホワイトリスト化に存在した不具合を解消しています。


## 利点(従来の方法との比較含む)
- 該当フォルダをドラッグ&ドロップだけで処理が完了します。
- 従来のホワイトリスト化の方法では**ゲームの更新やDLCが適用できない問題がありましたが、このツールではその点が解消されています。**
- 本体内蔵メモリーの内容だけをバックアップ・リストアするため、所要時間・必要サイズが最少ですみます。
- Vita TVを改造することなく利用可能です(最新のシステムソフトウェアでも動作します)。


## 利用方法
実行する前に、一通り手順に目を通してください。また下記のQ&Aも事前に確認をお願いします。
1. 処理時間およびバックアップ容量削減のため、Vita TVの電源を切り**メモリーカードとゲームカートリッジを取り外します(重要)**。
2. Vita TVの電源を入れVita TVのトロフィーアプリを起動し、トロフィー情報をPSNと同期します。
3. PCに最新の[コンテンツ管理アシスタント](http://cma.dl.playstation.net/cma/win/) をインストールします。
4. Vita TVの「コンテンツ管理」を起動し、PCとの接続に問題ない事を確認します。
5. 「バックアップユーティリティー」から「バックアップ」を選択し、名称は変更せずバックアップを実行します。  
NOTE: バックアップしたファイルはデフォルトでは `C:\Users\[ユーザー名]\Documents\PS Vita\SYSTEM\[16桁のID]\[作成日時作成時間]-01`フォルダに作成されます。  
例: `C:\Users\USER_NAME\Documents\PS Vita\SYSTEM\01234567ABCDEF\201912312359-01`  
6. [自動化ツール](https://github.com/1jtp8sobiu/ps_tv_whitelist/releases/v1.0/ps_tv_whitelist-win64.zip) をダウンロードし、PCの任意の場所に展開します。
7. ステップ5.で作成された`[作成日時作成時間]-01` ダウンロードした`ps_tv_whitelist.exe`にドラッグ&ドロップします。  
![](/ss.png)
8. 処理が完了したらVita TVの「コンテンツ管理」を起動し、「バックアップユーティリティー」から「リストア(復元)」を選択します。  
**NOTE: リストアする前に、メモリーカードが取り外されている事を必ず確認してください。メモリーカードが挿し込まれた状態で復元すると、内容が削除されてしまいます。**  
9. `999999999999-99`と言う名称のバックアップファイルを復元します。
10. リストア完了後、`999999999999-99`のバックアップファイルを削除し、Vita TVを再起動します。  
11. **メモリーカードを挿し込み**データベースの更新完了後、目的のゲームが起動するか確認します。


## Q&A
- **ホワイトリスト化を実行する上で注意することはありますか**  
主に以下の3点が挙げられます。  
1. Vita TV上でバックアップを作成する前にトロフィー情報をPSNと同期することをお勧めします(リストア時に、未同期のトロフィー情報は削除されるため)。  
2. リストアを実行後はPSNやPS Storeへの接続した際にパスワードの再入力が一度だけ必要になります(リストア時の仕様です)。もしパスワードを忘れている場合は事前に確認をお願いします。
3. リストア後は、ライブエリアのアイコンの配置やフォルダ情報などがリセットされるかもしれません。(未確認)
- **ホワイトリスト化を実行することでPSNアカウントや本体のBANの可能性はありますか？**  
データベースに簡易なトリガーを挿入しているだけの為、その心配はありません。  
- **必要なランタイムがダウンロードできず「コンテンツ管理アシスタント」のインストールができません**  
CMASetup.exeのプロパティ -> 互換性 -> 互換モード から "Windows XP Service Pack 3" を選択するとインストールできる場合があります。
- **ツールを実行できません**  
ツール実行時にアンチウイルスやWindows 10のスマートスクリーンの保護機能が動作する可能性があります。  
スマートスクリーンの保護画面は表示された場合は「詳細情報」をクリックして実行を選択してください。  
- **リストア時にメモリーカードと本体メモリーの内容が削除されると警告されますが問題ありませんか**  
メモリーカードが取り外されている状態であれば問題ありません(セーブデータ等は基本的にメモリカード側に保存されているため)。  
本体メモリーに関しても、バックアップ時のファイルをそのままリストアするため、データを失う事はありません。  
- **リストアが完了しましたが、インストール済みのダウンロード版のゲームが起動できません**  
メモリーカードを差し込みVita TVを起動するとデータベースが更新されゲームが起動可能になります。  
もしくは、PS Storeから該当ゲームを再度ダウンロードすると起動可能になります。(セーブデータは保持されます。)  
- **システムソフトウェアを更新するとホワイトリスト化は解除されますか**  
システムソフトウェアの更新後も維持されます。メモリーカードの入れ替え等でも維持されます。  
ホワイトリスト化が解除されるのは以下の場合です。  
 1. 本体設定を初期化した時(メモリーカードの初期化は問題なし)
 2. セーフモードから「データベースの再構築」を実行した時  
- **Vita TV非対応のゲームを起動させるとエラー[C2-12828-1]が発生します。(プレイ中にエラーが発生します。)**  
起動制限のためのフラグを変更しているだけであり、すべてのゲームが正常にプレイできる事を保証するものではありません。例えばカメラ機能やジャイロセンサーと言った機能が必須なゲームはVita TVでは正常に動作しません。
- **旧来のホワイトリスト化を導入済みですが、このツールを利用する場合はどうすればいいですか**  
まずセーフモードから「データベースの再構築」を実行し、旧来のホワイトリストを解除した後、このツールの手順に従ってください。
- **このツールで導入したホワイトリスト化を解除したい場合はどうすればいいですか**  
セーフモードから「データベースの再構築」を実行することで解除できます。
- **32bit版のWindowsで実行できますか**  
32bitのWindowsはサポートされていません。64bit上で実行してください。

## テスト環境
- Vita TV システムソフトウェア 3.73
- Windows 10 x64 Version 20H2 
- コンテンツ管理アシスタント Version 3.56.7933.1204

## 同梱済みツール
psvimgtools v0.1 (psvimgtools-0.1-win32.zip)  
https://github.com/yifanlu/psvimgtools/releases/tag/v0.1  

## 参考にしたページ
vitaTVの起動制限を解除する方法  
http://hp.vector.co.jp/authors/VA041465/How%20to%20install%20the%20PSTV%20Whitelist%20Patch.htm  
How to install the PSTV Whitelist Patch (v2)  
https://hackinformer.com/PlayStationGuide/PSV/tutorials/how_to_install_the_pstv_whitelist_patch_v2.html

## Credits
- Thanks to SilicaAndPina for his research for whitelist hack.
- Thanks to yifanlu for psvimgtools.
- Thanks to Davee and Proxima for http://cma.henkaku.xyz/.
