# TaskSchedular

Markdownファイルからタスクを読み取り、優先度を自動計算して整理表示するコマンドラインツールです。

## 概要

TaskSchedularは、Markdown形式のチェックリストを解析し、期限・優先度・タグなどのメタデータを元にタスクをスコアリングして、実行すべき順序で並び替えます。

### 主な機能

- ✅ **Markdownチェックリスト解析** - `- [ ]` 形式のタスクを自動認識
- 📅 **期限・開始日管理** - `due:`, `start:` メタデータでスケジュール管理
- 🎯 **自動優先度計算** - 期限の近さ、手動優先度、見積もり時間を考慮してスコアリング
- 🏷️ **タグベース推論** - タグやキーワードから最適な着手日を自動推定
- 🗓️ **今期の期間指定** - `period:` で今期を定義し、今期セクションのタスクに期末日を自動設定
- 👀 **ファイル監視モード** - ファイル変更を検知して自動的に再生成
- 🆕 **新規タスク検出** - 前回からの差分を **NEW** マークで表示

## インストール

### 必要要件

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) 以降

### ビルド方法

```bash
# リポジトリをクローン
git clone https://github.com/fujiihiroaki/task-schedular.git
cd task-schedular

# ビルド
dotnet build

# （オプション）Release版ビルド
dotnet build -c Release

# （オプション）AOT公開（Native実行ファイル生成）
dotnet publish -c Release
```

## 使い方

### 基本的な使用方法

#### 1. 一回だけ実行（onceモード）

```PowerShell
TaskSchedular.exe -- once <入力ファイル.md> [--out <出力ファイル.md>]
```

**例:**
```PowerShell
TaskSchedular.exe -- once plan.md --out prioritized.md
```

#### 2. ファイル監視モード（watchモード）

```PowerShell
TaskSchedular.exe -- watch <入力ファイル.md> [--out <出力ファイル.md>] [--debounce-ms <ミリ秒>]
```

**例:**
```PowerShell
# デフォルト設定（デバウンス1200ms）
TaskSchedular.exe -- watch plan.md

# カスタム設定
TaskSchedular.exe -- watch plan.md --out tasks.md --debounce-ms 500
```

watchモードでは、入力ファイルの変更を自動検知して出力ファイルを更新し続けます。終了するには `Ctrl+C` を押してください。

### 入力ファイルの書き方

#### 基本形式

```markdown
# 2026-02-15

- [ ] レポートを提出する due:2026-02-20 p:1 est:2h tag:urgent
- [ ] 会議資料を準備 due:2026-02-18 est:30m
- [x] メールを返信する

## バックログ

- [ ] ドキュメントを更新 tag:docs
```

#### 対応メタデータ

| メタデータ | 形式 | 説明 | 例 |
|-----------|------|------|-----|
| `due:` | `YYYY-MM-DD` | 期限日 | `due:2026-03-15` |
| `start:` | `YYYY-MM-DD` | 着手日（明示的に指定したい場合） | `start:2026-02-10` |
| `lead:` | `数値+単位` | リードタイム（d/w/m/y） | `lead:90d`, `lead:3m` |
| `pace:` | `slow\|normal\|fast` | ペース（leadを簡易指定） | `pace:normal` |
| `p:` | `数値` | 手動優先度（1が最高） | `p:1` |
| `est:` | `数値+単位` | 見積もり時間（m/h/d） | `est:30m`, `est:2h` |
| `tag:` | `文字列` | タグ（複数指定可） | `tag:urgent`, `tag:exam` |

#### 今期（period）の定義

```markdown
period: 2026-01-01 .. 2026-03-31

# 今期のバックログ
- [ ] 資料整理
- [ ] レビュー対応
```

`period:` が定義されている場合、セクション名が「今期の」で始まるタスクは期末日（上記なら `2026-03-31`）を `due` として自動設定します。`due:` が明示されている場合は上書きしません。

**ペースの自動変換:**
- `pace:slow` → 120日前から着手
- `pace:normal` → 90日前から着手
- `pace:fast` → 30日前から着手

**タグによる自動推論:**
タグやタイトルのキーワードから着手日を自動推定します：

| タグ/キーワード | リードタイム |
|---------------|-------------|
| `exam`, `cert`, `study`, 試験, 資格 | 90日 |
| `tax`, 確定申告, 申告 | 30日 |
| `travel`, 旅行, 出張 | 14日 |
| （デフォルト） | 7日 |

#### 見出しに日付を含める

```markdown
## 2026-02-20

- [ ] このタスクの期限は自動的に2026-02-20になる
```

見出しに `YYYY-MM-DD` 形式の日付を含めると、そのセクション内のタスクの期限として自動適用されます（`due:` 未指定の場合）。

### 出力例

```markdown
# Prioritized Tasks

- Source: `plan.md`
- Generated: `2026-02-07 12:30`

## 今すぐ（着手日/期限が今日以前）

- [ ] レポートを提出する **NEW** due:2026-02-20 start:2026-02-18 p:1 est:2h tag:urgent  <!-- id:a3f4b2c1 -->
  - score: `245` / reason: `p:1(+135), start:2026-02-18(+90), est:2h(+10), tag:urgent(+50)`

## 次にやる（〜2日）

- [ ] 会議資料を準備 due:2026-02-18 start:2026-02-17 est:30m  <!-- id:7d8e9f01 -->
  - score: `108` / reason: `start:2026-02-17(+90), est:30m(+18)`

## 30分以内で終わる系

_（なし）_

## 余裕があれば（先/期限なし）

- [ ] ドキュメントを更新 tag:docs  <!-- id:5c6a7b82 -->
  - score: `5` / reason: `no start/due(+5)`

## メタの書き方（例）
- `due:2026-06-15` 期限
- `start:2026-02-10` 着手日（書けるなら最優先で尊重）
- `pace:slow|normal|fast`（leadが難しい人向け）
- `tag:exam`（試験/資格は自動で早めに着手日を推定）
- `lead:90d`（書ける人だけ。d/w/m/y）
- `p:1`（手動優先） / `est:30m`（工数）
```

## スコアリングの仕組み

タスクの優先度スコアは以下の要素で計算されます：

1. **手動優先度** (`p:`): +135点（p:1の場合）〜 +0点
2. **緊急度** (着手日/期限): 
   - 今日以前: +120点
   - 1日以内: +90点
   - 3日以内: +70点
   - 7日以内: +40点
   - それ以降: +15点
3. **クイックウィン** (`est:`):
   - 15分以内: +25点
   - 30分以内: +18点
   - 1時間以内: +10点
4. **タグボーナス**:
   - `urgent`: +50点
   - `blocking`: +35点
5. **今日のセクション**: +15点

## 開発

### プロジェクト構造

```
TaskSchedular/
├── Program.cs              # エントリーポイント
├── TaskItem.cs             # タスクモデル
├── Runner.cs               # メイン処理フロー
├── MarkdownTaskParser.cs   # Markdown解析
├── TaskRanker.cs           # スコアリング・ランキング
├── MarkdownRenderer.cs     # Markdown出力
├── Inference.cs            # 開始日自動推論
└── WatchAgent.cs           # ファイル監視
```

### 依存関係

- **Markdig 0.44.0** - Markdown処理ライブラリ

### ビルド設定

- ターゲットフレームワーク: .NET 8.0
- AOTコンパイル対応 (`PublishAot: true`)
- グローバリゼーション無効化 (`InvariantGlobalization: true`)

### テスト

プロジェクトには53個のユニットテストと統合テストが含まれています。

```bash
# すべてのテストを実行
dotnet test

# 詳細な出力付きで実行
dotnet test --logger "console;verbosity=detailed"

# カバレッジレポート生成
dotnet test --collect:"XPlat Code Coverage"
```

**テストカバレッジ:**
- MarkdownTaskParser: 12テスト
- TaskRanker: 11テスト
- MarkdownRenderer: 11テスト
- Inference: 14テスト
- Runner統合テスト: 5テスト

## ライセンス

このプロジェクトは [Apache License 2.0](LICENSE) の下でライセンスされています。

```
Copyright 2026 Hiroaki Fujii

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## コントリビューション

プルリクエストやIssueを歓迎します！

## 作者

Hiroaki Fujii - [@fujiihiroaki](https://github.com/fujiihiroaki)

## リンク

- [GitHub Repository](https://github.com/fujiihiroaki/task-schedular)
- [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
