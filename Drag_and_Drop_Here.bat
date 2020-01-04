@echo off
title PlayStation TV Whitelister
cd /d %~dp0

set PSVIMGTOOLS_DIR=%~dp0\bin\psvimgtools
set SQLITE_DIR=%~dp0\bin\sqlite
set CMA_KEY_DERIV_DIR=%~dp0\CMAKeyDeriv
set PSVIMG_TEMP_DIR=%~dp0\bin\psvimg_temp

set PSVIMG_SOURCE_NAME=%~n1
set PSVIMG_SOURCE_DIR=%~dpn1

rem AIDの取得
set DIR_PATH_TEMP=%~dp1
set DIR_PATH=%DIR_PATH_TEMP:~0,-1%
for /F "delims=" %%i in ("%DIR_PATH%") do set PARENT_DIR_NAME=%%~nxi
set AID=%PARENT_DIR_NAME%

set PSVIMG_RESULT_NAME=999999999999-99

rem AIDの桁数取得
set STR=%AID%
set STR_LEN=0

:LOOP
if not "%STR%"=="" (
    set STR=%STR:~1%
    set /a STR_LEN=%STR_LEN%+1
    goto :LOOP
)

rem AIDの桁数チェック
if not "%STR_LEN%"=="16" (
	cls
	echo.
	echo ### （エラー！）指定されたフォルダが適切ではありません。確認後、再度バッチファイルにドラッグ＆ドロップしてください。
	goto :SKIP
)

rem .psvimgファイルの確認
if not exist "%PSVIMG_SOURCE_DIR%\%PSVIMG_SOURCE_NAME%.psvimg" (
	cls
	echo.
	echo ### （エラー！）指定されたフォルダが適切ではありません。確認後、再度バッチファイルにドラッグ＆ドロップしてください。
	goto :SKIP
)

echo ### TEMPディレクトリを削除...
rd /s /q "%PSVIMG_TEMP_DIR%"
rd /s /q "%DIR_PATH%\%PSVIMG_RESULT_NAME%"

cls
echo.
echo ### ホワイトリスト化処理を開始します。
echo ### （注）最大で5GBほどの容量が一時的に必要になる場合があります。ドライブの空き容量が十分にあるか確認してください。
echo.
echo ### バックアップファイルの展開に必要なCMA Keyを取得します。
echo ### 自動的にWebブラウザが開くので、表示された64桁のCMA Keyをコピーしてください。
echo ### （ http://cma.henkaku.xyz/?aid=%AID% にアクセスします。中止する場合はこの画面を閉じてください。）
echo ### （ Enterを押すとWebブラウザを開きます。）
set /p TEST=

start http://cma.henkaku.xyz/?aid=%AID%

:ENTER_CMA_KEY
echo.
echo ### （コピーした64桁のKeyを右クリックで貼り付けし、Enterで実行）
set /p CMA_KEY="---> "
)
echo.
echo ### 処理開始...

echo ### TEMPディレクトリ作成...
md "%PSVIMG_TEMP_DIR%"
md "%PSVIMG_TEMP_DIR%\dec"

echo ### .psvimgファイルを展開中...
"%PSVIMGTOOLS_DIR%\psvimg-extract.exe" -K %CMA_KEY% "%PSVIMG_SOURCE_DIR%\%PSVIMG_SOURCE_NAME%.psvimg" "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%" > "%PSVIMG_TEMP_DIR%\psvimg-extract.log"

echo ### logファイルのサイズチェック...
for %%j in ("%PSVIMG_TEMP_DIR%\psvimg-extract.log") do (
	set LOG_SIZE=%%~zj
)

if %LOG_SIZE%==0 (
	rd /s /q "%PSVIMG_TEMP_DIR%"
	cls
	echo.
	echo ### （エラー！） 入力されたCMA Keyが正しくありません。再入力してください。
	goto :ENTER_CMA_KEY
)

echo ### app.dbにホワイトリストハックを挿入中...
rem "%SQLITE_DIR%\sqlite3.exe" "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%\ur0_shell\db\app.db" "CREATE TRIGGER CHANGE_FEATURE_PSTV AFTER INSERT ON tbl_appinfo WHEN 1=1 BEGIN UPDATE tbl_appinfo SET val = val & ~8 WHERE key='2412347057' and titleid=new.titleid; END;"
rem "%SQLITE_DIR%\sqlite3.exe" "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%\ur0_shell\db\app.db" "CREATE TRIGGER SET_ATTRIBUTE_MINOR_TO_16 AFTER INSERT ON tbl_appinfo WHEN NEW.titleId LIKE 'PCS%%' and NEW.key LIKE '3168212510' BEGIN DELETE FROM tbl_appinfo WHERE titleId=NEW.titleId and key='2412347057'; INSERT INTO tbl_appinfo VALUES(NEW.titleId, '2412347057', 16); END;"

rem "VERSION"(3552295351) keyが作成された際に、"ATTRIBUTE_MINOR"(2412347057) keyの値をUPDATEしてBOOTABLEに。
rem "VERSION"(3552295351) keyが作成された際に、"ATTRIBUTE_MINOR"(2412347057) keyをINSERT。既にkeyが存在する場合はIGNORE。
rem バッチファイル内で % をエスケープするには %% と記述する。
rem "%SQLITE_DIR%\sqlite3.exe" "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%\ur0_shell\db\app.db" "CREATE TRIGGER tgr_SET_ATTRIBUTE_MINOR_TO_BOOTABLE AFTER INSERT ON tbl_appinfo WHEN NEW.titleId LIKE 'PCS%%' and NEW.key LIKE '3168212510' BEGIN UPDATE tbl_appinfo SET val = val & ~8 WHERE titleId = new.titleId AND key='2412347057'; INSERT OR IGNORE INTO tbl_appinfo VALUES(NEW.titleId, '2412347057', 16); END;"
"%SQLITE_DIR%\sqlite3.exe" "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%\ur0_shell\db\app.db" "CREATE TRIGGER tgr_SET_ATTRIBUTE_MINOR_TO_BOOTABLE AFTER INSERT ON tbl_appinfo WHEN NEW.titleId LIKE 'PCS%%' and NEW.key LIKE '3552295351' BEGIN UPDATE tbl_appinfo SET val = val & ~8 WHERE titleId = new.titleId AND key='2412347057'; INSERT OR IGNORE INTO tbl_appinfo VALUES(NEW.titleId, '2412347057', 16); END;"

echo ### .psvimgファイルをパック中...
md "%PSVIMG_TEMP_DIR%\enc"
"%PSVIMGTOOLS_DIR%\psvimg-create.exe" -n %PSVIMG_RESULT_NAME% -K %CMA_KEY% "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%" "%PSVIMG_TEMP_DIR%\enc\%PSVIMG_RESULT_NAME%" > "%PSVIMG_TEMP_DIR%\psvimg-create.log"

echo ### ファイル移動中...
md "%DIR_PATH%\%PSVIMG_RESULT_NAME%"
move "%PSVIMG_TEMP_DIR%\enc\%PSVIMG_RESULT_NAME%\%PSVIMG_RESULT_NAME%.psvimg" "%DIR_PATH%\%PSVIMG_RESULT_NAME%"
move "%PSVIMG_TEMP_DIR%\enc\%PSVIMG_RESULT_NAME%\%PSVIMG_RESULT_NAME%.psvinf" "%DIR_PATH%\%PSVIMG_RESULT_NAME%"
move "%PSVIMG_TEMP_DIR%\enc\%PSVIMG_RESULT_NAME%\%PSVIMG_RESULT_NAME%.psvmd" "%DIR_PATH%\%PSVIMG_RESULT_NAME%"

echo ### TEMPディレクトリを削除...
rd /s /q "%PSVIMG_TEMP_DIR%"

cls
echo.
echo ### 処理が完了しました。最後に以下を実行してホワイトリスト化完了です。
echo.
echo ### 1. PS TVの「コンテンツ管理」を起動し、「バックアップユーティリティー」から「リストア(復元)」を選択します。
echo ### 2.「%PSVIMG_RESULT_NAME%」と言う名称のバックアップファイルを復元します。
echo ### （注意）必ずメモリーカードを取り外した状態でリストアしてください。
echo.
echo ### 3. リストア完了後、「%PSVIMG_RESULT_NAME%」のバックアップファイルを削除し、再起動します。
echo ### 4. 再起動後メモリーカード・ゲームカートリッジを挿し込み、目的のゲームが起動できるか確認してください。
:SKIP
echo ### （Enterを押すとバッチファイルを終了します。）
set /p TEST=
