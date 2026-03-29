# Mirage

向いている方向に自分そっくりのダミーが走り出す、ブラフ用の試作薬です。

## 仕様

- 使用時に自分の見た目をコピーしたデコイを生成
- デコイは現在向いている方向へ直進
- 本人はそのまま操作可能
- デコイは攻撃しない / 無線しない / 当たり判定なし
- 数秒後に自動で消える

## 導入

`server.cfg` に以下を追加してください。

```cfg
ensure mirage_demo
```

## アイテム名

```lua
mirage
```

## ox_inventory 例

```lua
['mirage'] = {
    label = 'Mirage',
    weight = 100,
    stack = true,
    close = true,
    description = '向いている方向に囮を走らせる薬',
    client = {
        export = 'mirage_demo.useItem'
    }
},
```

## QBCore items.lua 例

```lua
['mirage'] = {
    ['name'] = 'mirage',
    ['label'] = 'Mirage',
    ['weight'] = 100,
    ['type'] = 'item',
    ['image'] = 'mirage.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = '向いている方向に囮を走らせる薬'
},
```

## 主な設定

```lua
Config.CooldownMs = 25000
Config.DecoyForwardDistance = 18.0
Config.DecoyRunSpeed = 1.25
Config.DecoyCleanupMs = 4500
```


## 追加したもの

- 使用時に pill アニメを再生
- デコイ生成時に ground Z を取り直して、地面を突き抜けにくく調整

### 追加 Config

```lua
Config.UsePillAnim = true
Config.PillAnimDict = 'mp_suicide'
Config.PillAnimClip = 'pill'
Config.PillAnimDuration = 2200

Config.DecoyGroundFix = true
Config.DecoyGroundOffset = 0.02
```


## 走行修正版
この版では Mirage デコイが
- 背面歩きっぽく見える
- 歩きのままになる
- 地面を抜ける

問題に合わせて、以下を修正しています。

- collision を有効化
- `move_m@brave` を適用
- `SetPedMoveRateOverride` で走行寄りに調整
- `TaskTurnPedToFaceCoord` を追加
- `TaskGoStraightToCoord` の heading 引数を `0.0` に変更
- `Config.DecoyRunSpeed = 2.0`
