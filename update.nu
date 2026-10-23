let version = http get https://api.github.com/repos/GDRETools/gdsdecomp/releases/latest
| get tag_name
| str replace 'v' ''

let url = $"https://github.com/GDRETools/gdsdecomp/releases/download/v($version)/GDRE_tools-v($version)-linux.zip"

let hash = nix-prefetch-url $url --type sha256
| nix hash convert --hash-algo sha256 $in
| str trim

open default.nix
| str replace -r 'version = "[^"]*"' $"version = \"($version)\""
| str replace -r 'sha256 = "[^"]*"' $"sha256 = \"($hash)\""
| save default.nix -f