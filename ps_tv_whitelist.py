#!/usr/bin/env python3

import hashlib
import os
import pathlib
import re
import shutil
import sqlite3
import subprocess
import sys
import tempfile

from Cryptodome.Cipher import AES


## https://qiita.com/firedfly/items/f6de5cfb446da4b53eeb
def resource_path(relative_path):
    if hasattr(sys, '_MEIPASS'):
        return os.path.join(sys._MEIPASS, relative_path)
    return os.path.join(os.path.abspath("."), relative_path)


def verifiy_aid(aid):
    if len(aid) == 16 and re.match('[0-9A-F]{16}', aid, re.IGNORECASE):
        return

    print('### [ERROR!] 適切なフォルダ/AIDではありません。')
    print('### 正しいフォルダを確認後、再度ドラッグ&ドロップしてください。')
    exit_(-1)


def psvimg_exist_check(psvimg_source):
    if os.path.isfile(psvimg_source):
        return

    print('### [ERROR!] 指定されたフォルダが適切ではありません。')
    print('### 正しいフォルダを確認後、再度ドラッグ&ドロップしてください。')
    exit_(-1)


def cma_keygen(aid):
    PASSPHRASE = 'Sri Jayewardenepura Kotte'
    PSVIMG_AES128ECB = 'A9FA5A62799FCC4C726B4E2CE3506D38'

    buffer = bytes.fromhex(aid) + PASSPHRASE.encode()
    enc = get_hash_value(buffer)
    key = bytes.fromhex(PSVIMG_AES128ECB)
    
    cipher = AES.new(key, AES.MODE_ECB)
    dec = cipher.decrypt(bytes.fromhex(enc))
    return dec.hex()


def get_hash_value(data, algo='sha256'):
    h = hashlib.new(algo)
    h.update(data)
    return h.hexdigest()


def inject_whitelist(db_name):
    conn = sqlite3.connect(db_name)
    cur = conn.cursor()

    # "VERSION"(3552295351) keyが作成された際に、"ATTRIBUTE_MINOR"(2412347057) keyの値をUPDATEしてBOOTABLEに。
    # "VERSION"(3552295351) keyが作成された際に、"ATTRIBUTE_MINOR"(2412347057) keyをINSERT。既にkeyが存在する場合はIGNORE。
    try:
        cur.execute("CREATE TRIGGER tgr_SET_ATTRIBUTE_MINOR_TO_BOOTABLE AFTER INSERT ON tbl_appinfo WHEN NEW.titleId LIKE 'PCS%' and NEW.key LIKE '3552295351' BEGIN UPDATE tbl_appinfo SET val = val & ~8 WHERE titleId = new.titleId AND key='2412347057'; INSERT OR IGNORE INTO tbl_appinfo VALUES(NEW.titleId, '2412347057', 16); END;")
        conn.commit()
        conn.close()
    except sqlite3.OperationalError:
        print('### [WARNING!] 既にホワイトリスト化されている可能性があります。')
        print('### 再度ホワイトリスト化を実行する場合は、Vita TVのセーフモードから「データベースの再構築」を実行し、システムのバックアップを作成し直してください。')
        conn.close()
        exit_(-2)


def print_description():
    print('### ホワイトリスト化処理を開始します。')
    print('### [注] 最大で 5GB ほどの容量が一時的に必要になる場合があります。')
    print()
    input('Enterを押すと処理を開始します。')
    print()
    print('### 処理開始...')


def print_result_description():
    print('### 処理が完了しました。最後に以下を実行してホワイトリスト化完了です。')
    print()
    print()
    print('     [注!!] 必ずメモリーカードを取り外した状態で以下を実行してください。')
    print()
    print()
    print('1. Vita TV から「コンテンツ管理」/「バックアップユーティリティー」/「リストア(復元)」を選択します。')
    print(f'2.「{PSVIMG_RESULT_NAME}」と言う名称のバックアップファイルを復元します。')
    print(f'3. リストア完了後、バックアップを削除するかどうかの選択肢で「はい」を選んで Vita TV を再起動します。')
    print('4. 再起動後メモリーカード・ゲームカートリッジを挿し込み目的のゲームが起動できるか確認します。')


def exit_(retcode):
    print()
    input('Enterを押すとスクリプトを終了します。')
    sys.exit(retcode)


def main():
    ## ソースフォルダの取得/AIDの取得
    source_dir = pathlib.Path(sys.argv[1])
    source_name = source_dir.stem
    parent_dir = source_dir.parents[0]
    psvimg_source = f'{source_dir}/{source_name}.psvimg'
    aid = str(parent_dir.stem)

    verifiy_aid(aid)
    cma_key = cma_keygen(aid)
    psvimg_exist_check(psvimg_source)

    print_description()
    with tempfile.TemporaryDirectory() as tmp_dir:
        ## 必要なフォルダを事前に作成
        os.makedirs(f'{tmp_dir}/dec', exist_ok=True)
        os.makedirs(f'{tmp_dir}/enc', exist_ok=True)

        print('### .psvimgを展開中...')
        cmd_list = [PSVIMG_EXT, '-K', cma_key, psvimg_source, f'{tmp_dir}/dec/{source_name}']
        proc = subprocess.run(cmd_list, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        ## psvimg展開結果確認
        db_name = f'{tmp_dir}/dec/{source_name}/ur0_shell/db/app.db'
        if not os.path.isfile(db_name):
            print('### [ERROR!] .psvimgを展開できません。適切なフォルダを指定しているか確認してください。')
            exit_(-1)

        print('### app.dbにホワイトリスト化実行...')
        inject_whitelist(db_name)

        print('### .psvimgファイルを再パック中...')
        cmd_list = [PSVIMG_CRE, '-n', PSVIMG_RESULT_NAME, '-K', cma_key, f'{tmp_dir}/dec/{source_name}', f'{tmp_dir}/enc/{PSVIMG_RESULT_NAME}']
        proc = subprocess.run(cmd_list, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        print('### ファイル移動中...')
        if os.path.isdir(f'{parent_dir}/{PSVIMG_RESULT_NAME}'):
            shutil.rmtree(f'{parent_dir}/{PSVIMG_RESULT_NAME}')
        shutil.move(f'{tmp_dir}/enc/{PSVIMG_RESULT_NAME}', f'{parent_dir}/{PSVIMG_RESULT_NAME}')
    print_result_description()
    exit_(0)


if __name__ == '__main__':
    ## 作業directory変更
    dpath = os.path.dirname(os.path.abspath(sys.argv[0]))
    os.chdir(dpath)

    PSVIMG_RESULT_NAME = '999999999999-99'
    PSVIMG_EXT = resource_path('psvimgtools/psvimg-extract.exe')
    PSVIMG_CRE = resource_path('psvimgtools/psvimg-create.exe')

    try:
        subprocess.run('cls', shell=True)
        subprocess.run('title PlayStation® TV Whitelister', shell=True)
    except:
        pass

    try:
        sys.argv[1]
    except IndexError:
        print('### [ERROR!] フォルダが指定されていません。')
        print('###「コンテンツ管理」でバックアップしたフォルダを確認してドラッグ&ドロップしてください。')
        exit_(-1)

    main()
