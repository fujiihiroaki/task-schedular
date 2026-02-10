## 1. データモデル拡張

- [x] 1.1 `TaskItem.cs` に `DateTime? PeriodEnd` プロパティを追加する

## 2. パーサー拡張

- [x] 2.1 `MarkdownTaskParser.cs` に `period:` 行を検出する正規表現を追加する（`period:\s*(\d{4}-\d{2}-\d{2})\s*\.\.\s*(\d{4}-\d{2}-\d{2})`）
- [x] 2.2 `Parse()` メソッド内で `period:` 行を解析し、期間終了日を保持するローカル変数を追加する
- [x] 2.3 パース済みの各 `TaskItem` に `PeriodEnd` を設定する

## 3. 推論ロジック拡張

- [x] 3.1 `Inference.cs` に今期セクション判定ロジックを追加する（セクション名が「今期の」で始まるか判定）
- [x] 3.2 `PeriodEnd` が設定済み かつ 今期セクション内 かつ `Due` 未指定のタスクに対して `Due = PeriodEnd` を設定するロジックを追加する

## 4. テスト

- [x] 4.1 `MarkdownTaskParserTests.cs` に `period:` 行の解析テストを追加する（有効な定義、未定義、複数定義）
- [x] 4.2 `InferenceTests.cs` または新規テストファイルに今期セクション内タスクへの `due` 自動設定テストを追加する（自動設定、明示的 due 維持、今期以外のセクション、period 未定義）
- [x] 4.3 既存テストが全件パスすることを確認する
