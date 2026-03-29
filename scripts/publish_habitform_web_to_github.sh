#!/usr/bin/env bash
# Yerel repo: mobil habitrise ile habitform-web GitHub projesini ayırır / ilk push.
# Kullanım: ./scripts/publish_habitform_web_to_github.sh
#
# Kimlik doğrulama (birini kullan):
#   • macOS Terminal: script interaktif olarak `gh auth login -w` açar
#   • Otomasyon: export GH_TOKEN=ghp_... veya GITHUB_TOKEN=ghp_...

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

REPO_SLUG="${HABITFORM_WEB_REPO_SLUG:-habitform-web}"
ORIGIN_URL="https://github.com/armagangok/${REPO_SLUG}.git"

unset CI
export PATH="/opt/homebrew/bin:$PATH"

TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI yok. Kur: brew install gh"
  exit 1
fi

ensure_gh_auth() {
  if gh auth status >/dev/null 2>&1; then
    return 0
  fi
  if [[ -n "${TOKEN}" ]]; then
    echo "${TOKEN}" | gh auth login --with-token -h github.com
    return 0
  fi
  echo "GitHub oturumu yok; tarayıcı ile giriş açılıyor..."
  gh auth login -h github.com -p https -w
}

create_repo_on_github() {
  # origin genelde yukarıda eklendi; GitHub’da boş depo aç (tek komut)
  gh repo create "${REPO_SLUG}" --public -d "HabitForm web"
}

assert_origin_safe_for_web() {
  local url
  url="$(git remote get-url origin 2>/dev/null)" || {
    echo "origin tanımlı değil."
    exit 1
  }
  case "${url}" in
  *habitrise*|*HabitRise*)
    echo "Güvenlik: origin mobil habitrise adresine işaret ediyor, push yapılmıyor: ${url}"
    exit 1
    ;;
  *"${REPO_SLUG}"*) ;;
  *)
    echo "Güvenlik: origin beklenen web repo (${REPO_SLUG}) değil: ${url}"
    exit 1
    ;;
  esac
}

push_branches() {
  assert_origin_safe_for_web
  git push -u origin main
  git push -u origin development 2>/dev/null || true
}

ensure_gh_auth

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "${ORIGIN_URL}"
fi

remote_ls_ok=false
if remote_ls_out="$(git ls-remote origin 2>&1)"; then
  remote_ls_ok=true
fi
if [[ "${remote_ls_ok}" == true ]] && [[ "${remote_ls_out}" != *"Repository not found"* ]]; then
  echo "Uzak depo hazır; push ediliyor..."
  push_branches
  echo "Tamam: ${ORIGIN_URL}"
  exit 0
fi

echo "GitHub'da '${REPO_SLUG}' oluşturuluyor..."
create_repo_on_github

remote_ls_ok=false
if remote_ls_out="$(git ls-remote origin 2>&1)"; then
  remote_ls_ok=true
fi
if [[ "${remote_ls_ok}" != true ]] || [[ "${remote_ls_out}" == *"Repository not found"* ]]; then
  echo "Uzak depo hâlâ erişilemiyor. GitHub'da repo adını / erişimi kontrol et."
  echo "${remote_ls_out}"
  exit 1
fi

push_branches
LOGIN="$(gh api user -q .login 2>/dev/null || echo armagangok)"
echo "Tamam: https://github.com/${LOGIN}/${REPO_SLUG}"
