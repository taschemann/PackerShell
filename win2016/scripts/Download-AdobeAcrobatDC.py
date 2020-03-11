#!/usr/bin/python

from ftplib import FTP

ftp = FTP('ftp.adobe.com')
ftp.login()
ftp.cwd('/pub/adobe/acrobat/win/AcrobatDC/')

ftp.quit()