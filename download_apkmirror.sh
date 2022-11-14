#!/usr/bin/env bash

declare -A apks

apks["com.twitter.android"]=dl_twitter
apks["com.google.android.youtube.apk"]=dl_yt
apks["tv.twitch.android.app"]=dl_twitch
apks["com.google.android.apps.youtube.music.apk"]=dl_ytm
apks["com.reddit.frontpage"]=dl_reddit

## Functions

# Wget user agent
WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0"

# Wget function
req() { wget -nv -O "$2" --header="$WGET_HEADER" "$1"; }

# Wget apk verions
get_apk_vers() { req "$1" - | sed -n 's;.*Version:</span><span class="infoSlide-value">\(.*\) </span>.*;\1;p'; }

# Wget apk verions(largest)
get_largest_ver() {
	local max=0
	while read -r v || [ -n "$v" ]; do
		if [[ ${v//[!0-9]/} -gt ${max//[!0-9]/} ]]; then max=$v; fi
	done
	if [[ $max = 0 ]]; then echo ""; else echo "$max"; fi
}

# Wget download apk
dl_apk() {
	local url=$1 regexp=$2 output=$3
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n "s/href=\"/@/g; s;.*${regexp}.*;\1;p")"
	echo "$url"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$output"
}

# Downloading twitter
dl_twitter() {
	echo "Downloading Twitter"
	local last_ver
	last_ver="$version"
	last_ver="${last_ver:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=twitter" | get_largest_ver)}"

	echo "Choosing version '${last_ver}'"
	local base_apk="com.twitter.android.apk"
	if [ ! -f "$base_apk" ]; then
		declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/twitter-inc/twitter/twitter-${last_ver//./-}-release/" \
			"APK</span>[^@]*@\([^#]*\)" \
			"$base_apk")
		echo "Twitter version: ${last_ver}"
		echo "downloaded from: [APKMirror - Twitter]($dl_url)"
	fi
}


# Downloading youtube
dl_yt() {
	echo "Downloading YouTube"
	local last_ver
	last_ver="$version"
	last_ver="${last_ver:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=youtube" | get_largest_ver)}"

	echo "Choosing version '${last_ver}'"
	local base_apk="com.google.android.youtube.apk"
	if [ ! -f "$base_apk" ]; then
		declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/google-inc/youtube/youtube-${last_ver//./-}-release/" \
			"APK</span>[^@]*@\([^#]*\)" \
			"$base_apk")
		echo "YouTube version: ${last_ver}"
		echo "downloaded from: [APKMirror - YouTube]($dl_url)"
	fi
}

# Downloading twitch
dl_twitch() {
	echo "Downloading Twitch"
	local last_ver
	last_ver="$version"
	last_ver="${last_ver:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=twitch" | get_largest_ver)}"

	echo "Choosing version '${last_ver}'"
	local base_apk="tv.twitch.android.app.apk"
	if [ ! -f "$base_apk" ]; then
		declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/twitch-interactive-inc/twitch/twitch-${last_ver//./-}-release/" \
			"APK</span>[^@]*@\([^#]*\)" \
			"$base_apk")
		echo "Twitch version: ${last_ver}"
		echo "downloaded from: [APKMirror - Twitch]($dl_url)"
	fi
}

# Architectures
ARM64_V8A="arm64-v8a"
ARM_V7A="arm-v7a"

# Downloading youtube music
dl_ytm() {
	local arch=$ARM64_V8A
	echo "Downloading YouTube Music (${arch})"
	local last_ver
	last_ver="$version"
	last_ver="${last_ver:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=youtube-music" | get_largest_ver)}"

	echo "Choosing version '${last_ver}'"
	local base_apk="com.google.android.apps.youtube.music.apk"
	if [ ! -f "$base_apk" ]; then
		if [ "$arch" = "$ARM64_V8A" ]; then
			local regexp_arch='arm64-v8a</div>[^@]*@\([^"]*\)'
		elif [ "$arch" = "$ARM_V7A" ]; then
			local regexp_arch='armeabi-v7a</div>[^@]*@\([^"]*\)'
		fi
		declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-${last_ver//./-}-release/" \
			"$regexp_arch" \
			"$base_apk")
		echo "\nYouTube Music (${arch}) version: ${last_ver}"
		echo "downloaded from: [APKMirror - YouTube Music ${arch}]($dl_url)"
	fi
}

# Downloading reddit
dl_reddit() {
	echo "Downloading Reddit"
	local last_ver
	last_ver="$version"
	last_ver="${last_ver:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=reddit" | get_largest_ver)}"

	echo "Choosing version '${last_ver}'"
	local base_apk="com.reddit.frontpage.apk"
	if [ ! -f "$base_apk" ]; then
		declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/redditinc/reddit/reddit-${last_ver//./-}-release/" \
			"APK</span>[^@]*@\([^#]*\)" \
			"$base_apk")
		echo "Reddit version: ${last_ver}"
		echo "downloaded from: [APKMirror - Reddit]($dl_url)"
	fi
}

## Main

for apk in "${!apks[@]}"; do
    if [ ! -f $apk ]; then
        echo "Downloading $apk"
        version=$(jq -r ".\"$apk\"" <versions.json)
        ${apks[$apk]}
    fi
done
