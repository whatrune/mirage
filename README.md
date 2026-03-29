# Mirage

独自開発の違法薬物のFiveM / QBCore 用スクリプトです。
方向に自分そっくりのダミーが走り出す、ブラフ用の試作薬です。

## 仕様

- 使用時に自分の見た目をコピーしたデコイを生成
- デコイは現在向いている方向へ直進
- 本人はそのままでデコイの操作可能
- デコイは攻撃しない。当たり判定はあるが無敵
- 5秒後に自動で消える
- 使用時に空腹ゲージが50減る

## 前提環境

- FiveM
- QBCore
- ox_inventory 系、または QBCore の useable item 運用

## インストール

1. リソースを `resources` 配下に配置します  
2. `server.cfg` に以下を追加します

```cfg
ensure Mirage
```

3. アイテム定義を追加します  
4. サーバーを再起動、またはリソースを再読み込みします

## アイテム名

```lua
mirage
```

## ox_inventory 例

```lua
['mirage'] = {
    label = 'ミラージュ',
    weight = 100,
    stack = true,
    close = true,
    description = '現実と蜃気楼の境界を一瞬だけ曖昧にする薬',
    client = {
        export = 'mirage.useItem',
        image = 'mirage.png'
    }
},
```

## インベントリ画像について

アイテム画像を表示する場合は、使用している inventory の画像フォルダへ  
`Mirage.png` を配置してください。

### 例

#### QBCore / qb-inventory 系
```txt
ox-inventory/web/images/Mirage.png
```


## 基本設定

主な設定は `shared/config.lua` から変更できます。


### 再使用時間

```lua
Config.CooldownMs = 25000
```


### デコイの走行距離

```lua
Config.DecoyForwardDistance = 18.0
```

### デコイの自動削除時間

```lua
Config.DecoyCleanupMs = 4500

```

## 導入後の確認項目

導入後は以下を確認してください。

item 使用で pill アニメが再生される
デコイが前方へ走り出す
デコイが地面を抜けずに生成される
使用者本人はそのまま操作できる
他プレイヤーからデコイが見える
空腹値が 50 以下の時に使用できない
使用時に空腹値が 50 減る

## 補足

Mirage は、追跡や逃走時に相手の視線をずらすためのブラフ系スクリプトです。
他スクリプトとの組み合わせによっては、見た目や走行距離、速度の調整が必要になる場合があります。
