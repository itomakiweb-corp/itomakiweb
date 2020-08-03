## Forumit! - フォーラム管理

### イメージ

1. Perlでの実装例
    - http://www.pluto-dm.com/cgi/
1. データ構造
```
// forums（firebase上で管理するかも？）
{
forumTitle: "ヴァルキリープロファイル",
forumKey: "valkyrieProfile",
}

// forums/${forumName}/thread
{
threadTitle: "雑談",
threadBody: "適当に雑談しましょう",
}

// forums/${forumName}/thread/${threadDocumentId}/messages
{
messageBody: "適当に雑談しましょう",
}
```

### 仕様（実装に合わせて随時修正）

1. 可変数のフォーラム一覧を表示する
1. フォーラム詳細（可変数のスレッド一覧）を表示/作成/編集/削除する
1. スレッド詳細（テーマと可変数のメッセージ一覧）を表示/作成/編集/削除する
1. メッセージ詳細を表示/作成/編集/削除する
