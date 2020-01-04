@echo off
title PlayStation TV Whitelister
cd /d %~dp0

set PSVIMGTOOLS_DIR=%~dp0\bin\psvimgtools
set SQLITE_DIR=%~dp0\bin\sqlite
set CMA_KEY_DERIV_DIR=%~dp0\CMAKeyDeriv
set PSVIMG_TEMP_DIR=%~dp0\bin\psvimg_temp

set PSVIMG_SOURCE_NAME=%~n1
set PSVIMG_SOURCE_DIR=%~dpn1

rem AID�̎擾
set DIR_PATH_TEMP=%~dp1
set DIR_PATH=%DIR_PATH_TEMP:~0,-1%
for /F "delims=" %%i in ("%DIR_PATH%") do set PARENT_DIR_NAME=%%~nxi
set AID=%PARENT_DIR_NAME%

set PSVIMG_RESULT_NAME=999999999999-99

rem AID�̌����擾
set STR=%AID%
set STR_LEN=0

:LOOP
if not "%STR%"=="" (
    set STR=%STR:~1%
    set /a STR_LEN=%STR_LEN%+1
    goto :LOOP
)

rem AID�̌����`�F�b�N
if not "%STR_LEN%"=="16" (
	cls
	echo.
	echo ### �i�G���[�I�j�w�肳�ꂽ�t�H���_���K�؂ł͂���܂���B�m�F��A�ēx�o�b�`�t�@�C���Ƀh���b�O���h���b�v���Ă��������B
	goto :SKIP
)

rem .psvimg�t�@�C���̊m�F
if not exist "%PSVIMG_SOURCE_DIR%\%PSVIMG_SOURCE_NAME%.psvimg" (
	cls
	echo.
	echo ### �i�G���[�I�j�w�肳�ꂽ�t�H���_���K�؂ł͂���܂���B�m�F��A�ēx�o�b�`�t�@�C���Ƀh���b�O���h���b�v���Ă��������B
	goto :SKIP
)

echo ### TEMP�f�B���N�g�����폜...
rd /s /q "%PSVIMG_TEMP_DIR%"
rd /s /q "%DIR_PATH%\%PSVIMG_RESULT_NAME%"

cls
echo.
echo ### �z���C�g���X�g���������J�n���܂��B
echo ### �i���j�ő��5GB�قǂ̗e�ʂ��ꎞ�I�ɕK�v�ɂȂ�ꍇ������܂��B�h���C�u�̋󂫗e�ʂ��\���ɂ��邩�m�F���Ă��������B
echo.
echo ### �o�b�N�A�b�v�t�@�C���̓W�J�ɕK�v��CMA Key���擾���܂��B
echo ### �����I��Web�u���E�U���J���̂ŁA�\�����ꂽ64����CMA Key���R�s�[���Ă��������B
echo ### �i http://cma.henkaku.xyz/?aid=%AID% �ɃA�N�Z�X���܂��B���~����ꍇ�͂��̉�ʂ���Ă��������B�j
echo ### �i Enter��������Web�u���E�U���J���܂��B�j
set /p TEST=

start http://cma.henkaku.xyz/?aid=%AID%

:ENTER_CMA_KEY
echo.
echo ### �i�R�s�[����64����Key���E�N���b�N�œ\��t�����AEnter�Ŏ��s�j
set /p CMA_KEY="---> "
)
echo.
echo ### �����J�n...

echo ### TEMP�f�B���N�g���쐬...
md "%PSVIMG_TEMP_DIR%"
md "%PSVIMG_TEMP_DIR%\dec"

echo ### .psvimg�t�@�C����W�J��...
"%PSVIMGTOOLS_DIR%\psvimg-extract.exe" -K %CMA_KEY% "%PSVIMG_SOURCE_DIR%\%PSVIMG_SOURCE_NAME%.psvimg" "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%" > "%PSVIMG_TEMP_DIR%\psvimg-extract.log"

echo ### log�t�@�C���̃T�C�Y�`�F�b�N...
for %%j in ("%PSVIMG_TEMP_DIR%\psvimg-extract.log") do (
	set LOG_SIZE=%%~zj
)

if %LOG_SIZE%==0 (
	rd /s /q "%PSVIMG_TEMP_DIR%"
	cls
	echo.
	echo ### �i�G���[�I�j ���͂��ꂽCMA Key������������܂���B�ē��͂��Ă��������B
	goto :ENTER_CMA_KEY
)

echo ### app.db�Ƀz���C�g���X�g�n�b�N��}����...
rem "%SQLITE_DIR%\sqlite3.exe" "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%\ur0_shell\db\app.db" "CREATE TRIGGER CHANGE_FEATURE_PSTV AFTER INSERT ON tbl_appinfo WHEN 1=1 BEGIN UPDATE tbl_appinfo SET val = val & ~8 WHERE key='2412347057' and titleid=new.titleid; END;"
rem "%SQLITE_DIR%\sqlite3.exe" "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%\ur0_shell\db\app.db" "CREATE TRIGGER SET_ATTRIBUTE_MINOR_TO_16 AFTER INSERT ON tbl_appinfo WHEN NEW.titleId LIKE 'PCS%%' and NEW.key LIKE '3168212510' BEGIN DELETE FROM tbl_appinfo WHERE titleId=NEW.titleId and key='2412347057'; INSERT INTO tbl_appinfo VALUES(NEW.titleId, '2412347057', 16); END;"

rem "VERSION"(3552295351) key���쐬���ꂽ�ۂɁA"ATTRIBUTE_MINOR"(2412347057) key�̒l��UPDATE����BOOTABLE�ɁB
rem "VERSION"(3552295351) key���쐬���ꂽ�ۂɁA"ATTRIBUTE_MINOR"(2412347057) key��INSERT�B����key�����݂���ꍇ��IGNORE�B
rem �o�b�`�t�@�C������ % ���G�X�P�[�v����ɂ� %% �ƋL�q����B
rem "%SQLITE_DIR%\sqlite3.exe" "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%\ur0_shell\db\app.db" "CREATE TRIGGER tgr_SET_ATTRIBUTE_MINOR_TO_BOOTABLE AFTER INSERT ON tbl_appinfo WHEN NEW.titleId LIKE 'PCS%%' and NEW.key LIKE '3168212510' BEGIN UPDATE tbl_appinfo SET val = val & ~8 WHERE titleId = new.titleId AND key='2412347057'; INSERT OR IGNORE INTO tbl_appinfo VALUES(NEW.titleId, '2412347057', 16); END;"
"%SQLITE_DIR%\sqlite3.exe" "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%\ur0_shell\db\app.db" "CREATE TRIGGER tgr_SET_ATTRIBUTE_MINOR_TO_BOOTABLE AFTER INSERT ON tbl_appinfo WHEN NEW.titleId LIKE 'PCS%%' and NEW.key LIKE '3552295351' BEGIN UPDATE tbl_appinfo SET val = val & ~8 WHERE titleId = new.titleId AND key='2412347057'; INSERT OR IGNORE INTO tbl_appinfo VALUES(NEW.titleId, '2412347057', 16); END;"

echo ### .psvimg�t�@�C�����p�b�N��...
md "%PSVIMG_TEMP_DIR%\enc"
"%PSVIMGTOOLS_DIR%\psvimg-create.exe" -n %PSVIMG_RESULT_NAME% -K %CMA_KEY% "%PSVIMG_TEMP_DIR%\dec\%PSVIMG_SOURCE_NAME%" "%PSVIMG_TEMP_DIR%\enc\%PSVIMG_RESULT_NAME%" > "%PSVIMG_TEMP_DIR%\psvimg-create.log"

echo ### �t�@�C���ړ���...
md "%DIR_PATH%\%PSVIMG_RESULT_NAME%"
move "%PSVIMG_TEMP_DIR%\enc\%PSVIMG_RESULT_NAME%\%PSVIMG_RESULT_NAME%.psvimg" "%DIR_PATH%\%PSVIMG_RESULT_NAME%"
move "%PSVIMG_TEMP_DIR%\enc\%PSVIMG_RESULT_NAME%\%PSVIMG_RESULT_NAME%.psvinf" "%DIR_PATH%\%PSVIMG_RESULT_NAME%"
move "%PSVIMG_TEMP_DIR%\enc\%PSVIMG_RESULT_NAME%\%PSVIMG_RESULT_NAME%.psvmd" "%DIR_PATH%\%PSVIMG_RESULT_NAME%"

echo ### TEMP�f�B���N�g�����폜...
rd /s /q "%PSVIMG_TEMP_DIR%"

cls
echo.
echo ### �������������܂����B�Ō�Ɉȉ������s���ăz���C�g���X�g�������ł��B
echo.
echo ### 1. PS TV�́u�R���e���c�Ǘ��v���N�����A�u�o�b�N�A�b�v���[�e�B���e�B�[�v����u���X�g�A(����)�v��I�����܂��B
echo ### 2.�u%PSVIMG_RESULT_NAME%�v�ƌ������̂̃o�b�N�A�b�v�t�@�C���𕜌����܂��B
echo ### �i���Ӂj�K���������[�J�[�h�����O������ԂŃ��X�g�A���Ă��������B
echo.
echo ### 3. ���X�g�A������A�u%PSVIMG_RESULT_NAME%�v�̃o�b�N�A�b�v�t�@�C�����폜���A�ċN�����܂��B
echo ### 4. �ċN���チ�����[�J�[�h�E�Q�[���J�[�g���b�W��}�����݁A�ړI�̃Q�[�����N���ł��邩�m�F���Ă��������B
:SKIP
echo ### �iEnter�������ƃo�b�`�t�@�C�����I�����܂��B�j
set /p TEST=
