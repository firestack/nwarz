
{
	description = "NWARS/AWS-SSM flake adapter for nix";
	
	# inputs.nixpkgs.url = "nixpkgs/nixos-20.09";
	inputs.flkutl.url = "github:numtide/flake-utils/flatten-tree-system";

	outputs = { self, nixpkgs, flkutl, nix }:
		let
			pkgs' = system: import nixpkgs {
				inherit system;
				overlays = [ self.overlay ];
			};
			
			mkSSM = {fetchzip, stdenv, lib, ...}: system: {version, hash}: 
				stdenv.mkDerivation {
					pname = "aws-ssm";
					inherit version;

					src = fetchzip {
						inherit hash;
						stripRoot = true;
						url = "https://s3.amazonaws.com/session-manager-downloads/plugin/${version}/${system}/sessionmanager-bundle.zip";
					};

					buildCommand = ''
							install -D --target $out/ $src/seelog.xml.template
							install -D --target $out/bin/ $src/bin/*
						'';

					meta = with lib; {
						description = "AWS Systems Manager Plugin";
						homepage = "https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-linux";
						license = licenses.mit;
						maintainers = [ ];
						platforms = platforms.darwin;
						inherit version;
					};
				};

			ssm-mac = let 
				sys = "x86_64-darwin";
				aws-sys = "mac";
				pkgs = pkgs' sys;
				mkSsm = mkSSM pkgs aws-sys;
			in {
				defaultPackage."${sys}" = (pkgs).aws-ssm;
				packages."${sys}" = {
					inherit (pkgs) aws-ssm;
				};
				overlay = final: prev: {
					aws-ssm = mkSsm {
						version = "1.2.54.0";
						hash = "sha256-FSDjHW7pcmzPt3Kk1+4MFucqLvbBlQVnU+7RemggPKk=";
					};
				};
			};

			ssm-linux = let 
				sys = "x86_64-linux";
				aws-sys = "linux";
				pkgs = pkgs' sys;
				mkSsm = mkSSM pkgs aws-sys;
			in {
				overlay = final: prev: {
				};
			};
		in ssm-mac;
}
# let 
# 	pkgs' = (flkutl.lib.eachDefaultSystem (system: 
# 		import nixpkgs { inherit system; overlays = [ self.overlay ]; }));
# 	# need: stdenv, fetchzip
# in {
# 	overlay = final: prev: {
# 		aws-ssm = {};
# 	};
# };




