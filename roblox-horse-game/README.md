# ホースランチ・レジェンド (Horse Ranch Legend)

馬を育成し、レースに出走し、血統を繋いで世代を重ねていくRoblox用ゲームのソース一式です。
セガ「スターホース」シリーズのゲーム性(育成→レース→血統)を参考にしていますが、
名称・キャラクター・アセットはすべてオリジナルです。商標・著作物の直接利用は行っていません。

## できること (MVP)

- **育成**: スピード/スタミナ/パワー/根性/賢さの5ステータスを調教で強化。エネルギー管理・怪我(コンディション悪化)あり。
- **血統・世代交代**: 父馬(Stallion)×母馬(Mare)を配合し、ステータスを遺伝(平均+突然変異)させた子馬を生産。世代(Generation)が記録される。
- **レース**: 距離ごとに異なるステータス重み付けでタイムを計算し着順を決定。参加者が少ない場合はNPC馬で頭数を補完。クライアント側でレースをプログレスバーアニメーションとして再生。
- **対戦・オンライン**: RemoteFunction/RemoteEventによるマッチングキュー。複数プレイヤーが同じレースに参加すると結果を共有。
- **永続化**: DataStoreServiceでプレイヤーごとの馬・コインを保存(自動セーブ + 退出時保存)。

## 構成 (Rojo)

```
roblox-horse-game/
  default.project.json
  src/
    ReplicatedStorage/Modules/   -- 共有ロジック(遺伝・レース計算・定数)
    ServerScriptService/         -- サーバー: データ保存・育成・配合・レース進行
    StarterPlayer/StarterPlayerScripts/  -- クライアントUI(厩舎/調教/配合/レース画面)
```

## セットアップ手順

1. [Rojo](https://rojo.space/) をインストール(VSCode拡張 + Roblox Studioプラグイン、または `aftman`/`foreman` でCLI導入)。
2. Roblox Studioで新規の空いプレイスを開く。
3. このディレクトリで `rojo serve` を実行。
4. Roblox StudioのRojoプラグインから `Connect` を押して同期。
5. Studioで再生(F5)すると、画面中央にUIが表示され、初期馬3頭(父馬・母馬・ランダム1頭)からプレイできます。

## 今後Studio側で追加すると良いもの

- 実際の3Dコースモデル、馬の3Dモデル/アニメーション(現状はUI上のプログレスバーでレースを表現)
- BGM/効果音
- ガチャ的な新馬購入・コイン獲得手段(現状はコインは配合コストなどに未使用。経済設計は今後の拡張ポイント)
- レース距離・着順に応じたコイン報酬などの経済ループ

## 馬の3Dモデル (Blender, `blender/`)

`blender/generate_horse.py` は、Blenderの Python API(`bpy`)でプリミティブ(箱・円錐)を
組み立ててローポリ調の馬メッシュを作り、GLB/FBXに書き出すヘッドレススクリプトです。

**注意**: この開発環境にはBlenderがインストールされておらず、実行・目視確認はできていません。
形状は三角関数で近似配置した見込み値なので、書き出し後にBlenderで開いて
プロポーションがおかしければスクリプト冒頭の定数(`NECK_ANGLE_DEG`など)を調整し、再実行してください。

### 実行方法(あなたのPCで)

```bash
blender --background --python blender/generate_horse.py -- \
  --output blender/output --name LowPolyHorse \
  --coat 0.55,0.32,0.18 --mane 0.16,0.09,0.05
```

- `--coat` / `--mane` はR,G,B(0〜1)。父馬・母馬・子馬で色違いを作りたい場合は
  この値を変えて複数回実行すればOKです。
- 出力は `blender/output/LowPolyHorse.glb` と `.fbx`。

### Roblox Studioへの取り込み

1. Studioで `Insert` → `Mesh` (または新しい3D Importer)から `.fbx` か `.glb` を選択してインポート。
2. インポートされた MeshPart を厩舎シーンやレースコースに配置。
3. 必要であればスケール調整(Blender側は1ユニット=1メートル換算で作っています)。

アニメーション(走る・待機モーション)は含まれていません。将来的にRigify等でリグを組み、
Robloxの Animation Editor で走行モーションを作る必要があります。
