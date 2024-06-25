# infinite_scroll_flutter_sample

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# このプロジェクトについて

このアプリはFlutterにおける無限スクロールを実装するサンプルです。 
このアプリには以下の機能があります。

- `http://numbersapi.com`を叩いて数字に関わるトリビアを1~100まで表示する
- 初回は40~59の数字を読み込み、読み込みが終わったら50が画面の一番下になるようにスクロールする
- 上下の方向にスクロールし表示数の残りが3個以下になったら未取り込みの数字のトリビアを10個追加ロードする
