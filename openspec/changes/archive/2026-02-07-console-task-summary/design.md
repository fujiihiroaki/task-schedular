## Context

Runner はランク付け結果を Markdown にレンダリングしてファイルに書き出すだけで、コンソールには更新ログしか表示しない。watch モード利用時に結果を即座に確認できるサマリーが必要。

## Goals / Non-Goals

**Goals:**
- once/watch の各実行で、優先タスクのサマリーをコンソールにプレーンテキストで表示する
- 「今すぐ」「次にやる」を全件表示し、5件未満の場合は残りをスコア順で補完する
- NEW マーク、スコア、セクション名を表示する

**Non-Goals:**
- Markdown ファイル出力の内容や構成の変更
- スコアリングやタスク分類ルールの変更
- 出力件数やフォーマットのユーザー設定化

## Decisions

- **Runner 内にコンソール出力用のヘルパーを追加する**
  - ランク付け済みリストを再利用してサマリーを生成し、既存フローの中で出力する。
- **セクション判定は Start/Due の effective date を用いて MarkdownRenderer と同じ閾値で分類する**
  - 今すぐ: <= today
  - 次にやる: today+1〜today+2
  - それ以外は補完候補に回し、スコア降順で不足分を埋める。
- **差分なしのケースでもサマリーを表示する**
  - watch モードでの再出力要求に合わせ、Runner の早期 return 前にサマリーを出力する。

## Risks / Trade-offs

- **[Risk]** MarkdownRenderer と分類ロジックが重複して乖離する可能性 → **Mitigation:** helper 内に閾値を明示し、変更時は両方を更新する運用にする
- **[Trade-off]** watch モードでの出力が増える → **Mitigation:** 5件以内の簡潔なフォーマットに限定する

## Migration Plan

- 既存ファイル出力と互換性を維持するため追加の移行作業は不要
- ロールバックは該当変更の revert のみで対応可能

## Open Questions

- なし
