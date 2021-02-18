# -*- mode: python ; coding: utf-8 -*-

block_cipher = None


a = Analysis(['ps_tv_whitelist.py'],
             pathex=['Y:\\github\\ps_tv_whitelist'],
             binaries=[],
             datas=[],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
a.datas += [('.\\psvimgtools\\psvimg-create.exe', '.\\psvimgtools\\psvimg-create.exe', 'DATA')]
a.datas += [('.\\psvimgtools\\psvimg-extract.exe', '.\\psvimgtools\\psvimg-extract.exe', 'DATA')]
a.datas += [('.\\psvimgtools\\cyggcc_s-1.dll', '.\\psvimgtools\\cyggcc_s-1.dll', 'DATA')]
a.datas += [('.\\psvimgtools\\cyggcrypt-20.dll', '.\\psvimgtools\\cyggcrypt-20.dll', 'DATA')]
a.datas += [('.\\psvimgtools\\cyggpg-error-0.dll', '.\\psvimgtools\\cyggpg-error-0.dll', 'DATA')]
a.datas += [('.\\psvimgtools\\cygiconv-2.dll', '.\\psvimgtools\\cygiconv-2.dll', 'DATA')]
a.datas += [('.\\psvimgtools\\cygintl-8.dll', '.\\psvimgtools\\cygintl-8.dll', 'DATA')]
a.datas += [('.\\psvimgtools\\cygwin1.dll', '.\\psvimgtools\\cygwin1.dll', 'DATA')]
a.datas += [('.\\psvimgtools\\cygz.dll', '.\\psvimgtools\\cygz.dll', 'DATA')]
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name='ps_tv_whitelist',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          upx_exclude=[],
          runtime_tmpdir=None,
          console=True )
