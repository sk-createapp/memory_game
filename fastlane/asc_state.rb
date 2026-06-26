# App Store Connect 提出準備状態の読み取り専用ダンプ（検証用 / 無害）。
#
#   cd /Users/user/work/memory_game
#   export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
#   set -a; source /Users/user/work/meal-plan/fastlane/.env; set +a
#   export ASC_KEY_FILEPATH="/Users/user/work/meal-plan/fastlane/private_keys/AuthKey_2Y64997894.p8"
#   /Users/user/.local/share/mise/installs/ruby/3.3.11/bin/ruby fastlane/asc_state.rb
#
# 認証情報の在処は docs/asc-submission-setup.md / メモ ios-asc-distribution と同じ。
require 'spaceship'
require 'json'

token = Spaceship::ConnectAPI::Token.create(
  key_id: ENV.fetch('ASC_KEY_ID'),
  issuer_id: ENV.fetch('ASC_ISSUER_ID'),
  filepath: ENV.fetch('ASC_KEY_FILEPATH')
)
Spaceship::ConnectAPI.token = token
C  = Spaceship::ConnectAPI.client
TC = C.instance_variable_get(:@tunes_request_client)
def get(tc, path, params = nil) tc.get(path, params).body rescue { 'error' => $!.message } end

app  = Spaceship::ConnectAPI::App.find('com.skcreation.memorygame')
info = C.get_app_infos(app_id: app.id).first
ai   = get(TC, "v1/appInfos/#{info.id}")['data']['attributes']
vers = app.get_app_store_versions.find { |v| v.app_store_state == 'PREPARE_FOR_SUBMISSION' } ||
       app.get_app_store_versions.first
vid  = vers.id
vd   = get(TC, "v1/appStoreVersions/#{vid}")['data']['attributes']

puts "APP            #{app.name} (#{app.bundle_id}) id=#{app.id}"
puts "VERSION        #{vd['versionString']}  state=#{vd['appStoreState']}  releaseType=#{vd['releaseType']}"
b = get(TC, "v1/appStoreVersions/#{vid}/build")['data']
puts "BUILD          #{b ? b['id'][0, 8] : 'NONE attached'}"
puts "AGE RATING     #{ai['appStoreAgeRating']}"
ard = get(TC, "v1/appInfos/#{info.id}", { 'include' => 'ageRatingDeclaration' })
adv = (ard['included'] || []).find { |i| i['type'] == 'ageRatingDeclarations' }&.dig('attributes', 'advertising')
puts "  advertising  #{adv.inspect}  (広告表示アプリは true 必須)"
puts "CONTENT RIGHTS #{app.content_rights_declaration}"

mp = get(TC, "v1/appPriceSchedules/#{app.id}/manualPrices", { 'include' => 'appPricePoint', 'limit' => 3 })
pp = (mp['included'] || []).select { |i| i['type'] == 'appPricePoints' }.map { |p| p.dig('attributes', 'customerPrice') }
puts "PRICE          #{pp.empty? ? 'NOT SET' : pp.inspect}"

puts "\n-- localizations --"
info.get_app_info_localizations.each do |l|
  vl = vers.get_app_store_version_localizations.find { |x| x.locale == l.locale }
  sc = vl ? (vl.get_app_screenshot_sets.sum { |s| s.app_screenshots&.size || 0 } rescue '?') : '-'
  puts "  #{l.locale.ljust(7)} privacyUrl=#{l.privacy_policy_url ? 'Y' : 'N'}  supportUrl=#{vl&.support_url ? 'Y' : 'N'}  screenshots=#{sc}"
end

rd = vers.fetch_app_store_review_detail rescue nil
puts "\nREVIEW CONTACT #{rd ? "#{rd.contact_email} demoRequired=#{rd.demo_account_required}" : 'NONE'}"

sub = get(TC, 'v1/subscriptions/6784249796')['data']['attributes']
puts "SUBSCRIPTION   premium_monthly state=#{sub['state']}"
puts "\n(残: スクリーンショット / 有料App契約 / 最終提出 — docs/asc-submission-setup.md 参照)"
