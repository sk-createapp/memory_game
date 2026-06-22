# 効果音の出どころ（プロヴェナンス）

`assets/sounds/` の効果音はすべて [Pixabay](https://pixabay.com/) の音源。
Pixabay コンテンツライセンス（商用利用可・クレジット表記不要。素材そのものを
単体の素材として再配布・再販することは不可だが、アプリへの組み込みは可）。
<https://pixabay.com/service/license-summary/>

差し替える場合は各ページを開き、ダウンロードした mp3 を下表のファイル名に置く。
操作音だけは低レイテンシ再生のため WAV に変換する:

```sh
ffmpeg -y -i <bubble-pop>.mp3 -ac 1 -ar 44100 assets/sounds/tap.wav
```

| アプリ内ファイル | 用途 | タイトル / 作者 | ページ |
|---|---|---|---|
| `tap.wav` | 操作音 | Bubble Pop 06 / universfield | https://pixabay.com/sound-effects/film-special-effects-bubble-pop-06-351337/ |
| `clear_win.mp3` | クリア（ジングル） | piglevelwin2 / freesound_community | https://pixabay.com/sound-effects/musical-piglevelwin2mp3-14800/ |
| `clear_applause.mp3` | クリア（拍手） | Applause / driken5482 | https://pixabay.com/sound-effects/people-applause-236785/ |
| `fanfare_1.mp3` | 新記録（ファンファーレ・ランダム） | Cinematic Awards Fanfare 2 / pietiX | https://pixabay.com/sound-effects/musical-cinematic-awards-fanfare-2-527242/ |
| `fanfare_2.mp3` | 新記録（ファンファーレ・ランダム） | Cinematic Awards Fanfare 3 / pietiX | https://pixabay.com/sound-effects/film-special-effects-cinematic-awards-fanfare-3-527243/ |
| `fanfare_3.mp3` | 新記録（ファンファーレ・ランダム） | Cinematic Awards Fanfare 4 / pietiX | https://pixabay.com/sound-effects/film-special-effects-cinematic-awards-fanfare-4-527245/ |
| `newrecord_cheer.mp3` | 新記録（歓声） | Applause, cheer / driken5482 | https://pixabay.com/sound-effects/people-applause-cheer-236786/ |
| `fail.mp3` | 失敗 | Fail Trumpet / universfield | https://pixabay.com/sound-effects/musical-fail-trumpet-242645/ |

再生ロジックは `lib/services/sound_service.dart`。クリアと新記録は「メロディ＋群衆」を
重ねて全長そのまま鳴らし、ホームに戻るとフェードアウトする。
