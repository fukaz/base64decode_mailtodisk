# base64decode_mailtodisk
Base64デコード機能付きmailtodisk

## Description
xamppのmailtodiskを使用すると c:\xampp\mailoutput にメールがテキストファイルで出力されますが、出力されたものはBase64エンコードされたままなようなので、デコード機能を付けたものを作成しました。

## Usage
Perlで作成したのでWindowsにPerlのパスを通します。

## Install
mailtodisk.pl を c:\xampp\mailtodisk に入れます。
あとは、php.ini の sendmail_path を下記の通りに設定します。

`sendmail_path = "perl \"C:\xampp\mailtodisk\mailtodisk.pl\""`

