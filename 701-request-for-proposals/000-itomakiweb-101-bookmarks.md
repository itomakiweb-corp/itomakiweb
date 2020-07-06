## Bookmarkit! - ブックマーク管理

### イメージ

1. Nuxt.jsでの実装例
    - https://itomakiweb-bbs.web.app/bookmarks/JkNmoypDeqGGzqmT6p6E
1. データ構造（再帰構造）
    ```
      {
        // required
        // pointX: 0,
        // pointY: 0,
        sizeX: 1,
        sizeY: 1,
        clickCount: 0,
        url: 'https://hemino.com/',
        // TODO 内部用のURLを保存するかも 内部遷移用
        // TODO bottomNaviのmode選択再検討
        title: 'ヘミノ',

        // optional
        titleShort: 'Hemino',
        body: 'ヘミノ：興味と知識の集約サイト',
        // body: '',
        icon: 'https://hemino.com/2b.png', // このブックマークのアイコン
        showIcon: true,
        image: '', // このブックマークの横長画像
        showImage: false,
        backgroundColor: '',
        color: '',
        bookmarkItems: [
        ],
        assigneeItems: [],
        tagItems: [],
        // labels: [],
        projectItems: [],
        // milestone: '',
        milestoneItems: [],
        html: {
          head: {
            // common
            charset: '',
            title: '',
            appleMobileWebAppTitle: '', // titleShort
            description: '',
            keywords: '',
            icon: '', // pc favicon
            shortcutIcon: '', // pc favicon old
            appleTouchIcon: '', // iOS, Android touch icon

            // extra
            manifest: '',
            mobileWebAppCapable: '', // 全画面表示
            viewport: '', // iOS, Android 表示指定
            author: '',
            themeColor: '',
            formatDetection: '',
            // stylesheets: [],

            // OGP
            og: '', //  TOP: website、TOP以外: article
            ogUrl: '',
            ogType: '', //  TOP: website、TOP以外: article
            ogTitle: '', // 20文字以内で設定することが好ましい
            ogDescription: '', // 80~90文字が最適
            ogSiteName: '',
            ogLocale: '', // ja_JP
            ogImage: '', // 1200×630、比率で1.91：1を推奨, 絶対パス

            // OGP Facebook
            fbAppId: '', // 15文字の半角数字, 推奨
            fbAdmins: '', // 15文字の半角数字, 個人ID, 非推奨

            // OGP Twitter
            twitterCard: '', // summary, summary_large_image, photo, gallery, app
            twitterSite: '', // @twitterId
            twitterPlayer: '', // @twitterId
          },
        },
      }
    ```

### 仕様（実装に合わせて随時修正）

1. 可変数のブックマーク一覧を表示する
1. ブックマーク詳細（固定数のリンク一覧）を表示する
1. ブックマーク詳細（固定数のリンク一覧）を作成する
1. ブックマーク詳細（固定数のリンク一覧）を編集する
1. ブックマーク詳細（固定数のリンク一覧）を削除する
1. リンク詳細毎に、アイコンを手動設定可能とする
1. リンク詳細毎に、アイコンを自動設定可能とする（リンク先をパースして、faviconなどを取得する）
1. クリック数を可視化する
    1. 全体のクリック数に対する割合で、7段階の虹色で表現する
    1. 初期段階では、クリック時にリアルタイムでクリック数増加
    1. 安定段階では、負荷対策のため、バッチ処理でクリック数増加


### TODO

1. formの表示
    1. URL入力ボックス・タイトル入力ボックス・送信ボタンを最低限表示
        - https://api.flutter.dev/flutter/material/TextField-class.html
    1. 送信ボタンをクリック後に、URL・タイトルの入力値を取得
        - https://qiita.com/kurun_pan/items/3378875ff034614f381a
    1. 取得した値を、firestoreに保存
        - サンプルで実装済み
1. 要素の表示
1. 情報の取得
1. 要素の整形（表のように表示）
1. アイコンの設定
1. パッケージ名の設定
1. authの設定
