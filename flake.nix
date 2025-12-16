{
  description = "OpenWISP Controller - Network and WiFi controller";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
        flake-parts.flakeModules.easyOverlay
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devshells.default = {
          packages = with pkgs; [
            config.packages.pythonWithDeps
            git
          ];

          env = [
            {
              name = "PYTHONPATH";
              value = "./tests";
            }
          ];

          commands = [
            {
              name = "install-deps";
              command = "pip install -r requirements.txt -r requirements-test.txt";
              help = "Install Python dependencies";
            }
            {
              name = "run-tests";
              command = "./runtests";
              help = "Run the test suite";
            }
            {
              name = "run-qa";
              command = "./run-qa-checks";
              help = "Run QA checks";
            }
          ];
        };

        overlayAttrs = {
          inherit (config.packages)
            openwisp-controller
            ;
        };

        packages = {
          pythonWithDeps = pkgs.python3.withPackages (ps: [
            config.packages.openwisp-controller
            ps.pytest
            ps.coverage
            ps.django-redis
            ps.mock-ssh-server
            ps.responses
          ]);

          # Git-based dependencies
          netjsonconfig = pkgs.python3Packages.buildPythonPackage {
            pname = "netjsonconfig";
            version = "1.3";
            src = builtins.fetchTarball {
              url = "https://github.com/openwisp/netjsonconfig/archive/refs/heads/1.3.tar.gz";
              sha256 = "08i6dink4ki1hq8adg9pm0l6frvvbdvm8zzqlbsv8nk517x1mvc3";
            };
            format = "setuptools";
            propagatedBuildInputs = with pkgs.python3Packages; [ django djangorestframework ];
            doCheck = false;
          };

          django-x509 = pkgs.python3Packages.buildPythonPackage {
            pname = "django-x509";
            version = "1.4";
            src = builtins.fetchTarball {
              url = "https://github.com/openwisp/django-x509/archive/refs/heads/1.4.tar.gz";
              sha256 = "00d8ldv4594q3if9mlxwiwfn1gs3vmqd7al5inhrsi65rmmqifqs";
            };
            format = "setuptools";
            propagatedBuildInputs = with pkgs.python3Packages; [ django cryptography ];
            doCheck = false;
          };

          django-loci = pkgs.python3Packages.buildPythonPackage {
            pname = "django-loci";
            version = "1.3";
            src = builtins.fetchTarball {
              url = "https://github.com/openwisp/django-loci/archive/refs/heads/1.3.tar.gz";
              sha256 = "0yrmkmialp69jq2v33id6pmcp7mzc6xqv691ri7v3h6f6jym0vf1";
            };
            format = "setuptools";
            propagatedBuildInputs = with pkgs.python3Packages; [ django djangorestframework ];
            doCheck = false;
          };

          django-flat-json-widget = pkgs.python3Packages.buildPythonPackage {
            pname = "django-flat-json-widget";
            version = "0.5";
            src = builtins.fetchTarball {
              url = "https://github.com/openwisp/django-flat-json-widget/archive/refs/heads/0.5.tar.gz";
              sha256 = "0bhrz80qw0gdqgd4brzaaj8h8prjamk4ndpn7m7vfqhy4f2gavbs";
            };
            format = "setuptools";
            propagatedBuildInputs = with pkgs.python3Packages; [ django ];
            doCheck = false;
          };

           djangorestframework-gis = pkgs.python3Packages.buildPythonPackage {
             pname = "djangorestframework-gis";
             version = "1.2.0";
             src = builtins.fetchTarball {
               url = "https://github.com/openwisp/django-rest-framework-gis/archive/refs/tags/v1.2.0.tar.gz";
               sha256 = "1zdr2mdbihhs6jryzc7lx1vi9rvcw690zhcspq6mzynvccr25i7s";
             };
             format = "setuptools";
             propagatedBuildInputs = with pkgs.python3Packages; [ django djangorestframework ];
             doCheck = false;
           };

          django-sortedm2m = pkgs.python3Packages.buildPythonPackage {
            pname = "django-sortedm2m";
            version = "4.0.0";
            src = builtins.fetchTarball {
              url = "https://github.com/jazzband/django-sortedm2m/archive/refs/tags/4.0.0.tar.gz";
              sha256 = "13sm7axrmk60ai8jcd17x490yhg0svdmfj927vvfkq4lszmc5g96";
            };
            format = "setuptools";
            propagatedBuildInputs = with pkgs.python3Packages; [ django ];
            doCheck = false;
          };

          openwisp-utils = pkgs.python3Packages.buildPythonPackage {
            pname = "openwisp-utils";
            version = "1.3";
            src = builtins.fetchTarball {
              url = "https://github.com/openwisp/openwisp-utils/archive/refs/heads/1.3.tar.gz";
              sha256 = "1phgbjakswb0qy87xyykbmjv7xaxqi94qy3pbswl3kxamg2ahrxw";
            };
            format = "setuptools";
            propagatedBuildInputs = with pkgs.python3Packages; [ django djangorestframework celery channels ];
            doCheck = false;
          };

          openwisp-users = pkgs.python3Packages.buildPythonPackage {
            pname = "openwisp-users";
            version = "1.3";
            src = builtins.fetchTarball {
              url = "https://github.com/openwisp/openwisp-users/archive/refs/heads/1.3.tar.gz";
              sha256 = "0c7slzm6qazw456g5rrqgqv1nfrkm4hj7nmid5j2yn15iv8rdjih";
            };
            format = "setuptools";
            propagatedBuildInputs = with pkgs.python3Packages; [ django config.packages.openwisp-utils ];
            doCheck = false;
          };

          openwisp-notifications = pkgs.python3Packages.buildPythonPackage {
            pname = "openwisp-notifications";
            version = "1.3";
            src = builtins.fetchTarball {
              url = "https://github.com/openwisp/openwisp-notifications/archive/refs/heads/1.3.tar.gz";
              sha256 = "1ff7ax2widqp9p3qfpxnbhgsgxzsijqnnwxpbmxf9yqni97gzdia";
            };
            format = "setuptools";
            propagatedBuildInputs = with pkgs.python3Packages; [ django config.packages.openwisp-utils ];
            doCheck = false;
          };

          openwisp-ipam = pkgs.python3Packages.buildPythonPackage {
            pname = "openwisp-ipam";
            version = "1.3";
            src = builtins.fetchTarball {
              url = "https://github.com/openwisp/openwisp-ipam/archive/refs/heads/1.3.tar.gz";
              sha256 = "0lrv6vmzqxvs6xmppg4s33xgrvrq7cny07fdjp6rynw2g4akjwdj";
            };
            format = "setuptools";
            propagatedBuildInputs = with pkgs.python3Packages; [ django config.packages.openwisp-utils ];
            doCheck = false;
          };

          openwisp-controller = pkgs.python3Packages.buildPythonApplication {
            pname = "openwisp-controller";
            version = "1.1.5"; # Update to actual version from openwisp_controller/__init__.py
            src = ./.;

            format = "setuptools";

            propagatedBuildInputs = with pkgs.python3Packages; [
              django
              djangorestframework
              config.packages.djangorestframework-gis
              paramiko
              scp
              shortuuid
              netaddr
              django-import-export
              config.packages.django-sortedm2m
              django-reversion
              django-taggit
              django-cache-memoize
              config.packages.netjsonconfig
              config.packages.django-x509
              config.packages.django-loci
              config.packages.openwisp-utils
              config.packages.openwisp-users
              config.packages.openwisp-notifications
              config.packages.openwisp-ipam
            ];

            doCheck = false;
          };
        };
      };

      flake = {
        nixosModules.openwisp-controller = { config, lib, pkgs, ... }: {
          options.services.openwisp-controller = {
            enable = lib.mkEnableOption "OpenWISP Controller";
            package = lib.mkOption {
              type = lib.types.package;
              default = null;
              description = "The openwisp-controller package (set to inputs.openwisp-controller.packages.\${system}.openwisp-controller)";
            };
            port = lib.mkOption {
              type = lib.types.int;
              default = 8000;
              description = "Port to run the WSGI server on";
            };
            nginx = {
              enable = lib.mkEnableOption "Nginx reverse proxy";
              hostname = lib.mkOption {
                type = lib.types.str;
                description = "Hostname to listen on for openwisp-controller";
              };
              extraConfig = lib.mkOption {
                type = lib.types.attrs;
                default = {};
                description = "Extra configuration for the Nginx virtual host";
              };
            };
            database = {
              user = lib.mkOption {
                type = lib.types.str;
                default = "openwisp";
                description = "Database user";
              };
            };
            settingsModule = lib.mkOption {
              type = lib.types.str;
              default = "openwisp_controller.settings";
              description = "Django settings module";
            };
          };
          config = let
            owc-config = config.services.openwisp-controller;
          in lib.mkIf owc-config.enable {
            services.postgresql = {
              enable = true;
              ensureDatabases = [ owc-config.database.user ];
              ensureUsers = [{
                name = owc-config.database.user;
                ensureDBOwnership = true;
                ensureClauses = {
                  login = true;
                };
              }];
            };

            services.redis = {
              enable = true;
            };

            systemd.services.openwisp-controller = {
              description = "OpenWISP Controller";
              after = [
                "network.target"
                "postgresql.service"
                "redis.service"
              ];
              wantedBy = [ "multi-user.target" ];
              serviceConfig = {
                # ExecStartPre = [
                #   "${pkgs.python3}/bin/python ${./.}/manage.py migrate --settings=${owc-config.settingsModule} --noinput"
                # ];
                ExecStart = "${pkgs.python3Packages.gunicorn}/bin/gunicorn openwisp_controller.wsgi:application --bind 127.0.0.1:${toString owc-config.port} --workers 3";
                WorkingDirectory = "${./.}";
                Environment = ''
                  PYTHONPATH=${./.}:${pkgs.python3.withPackages (ps: [ owc-config.package ])}/lib/python3.13/site-packages
                  DATABASE_URL=postgresql://${owc-config.database.user}@localhost/${owc-config.database.user}
                  REDIS_URL=redis://localhost:6379/0
                '';
                DynamicUser = true;
              };
            };

            services.nginx = lib.mkIf owc-config.nginx.enable {
              enable = true;
              virtualHosts."${owc-config.nginx.hostname}" = lib.mkMerge [
                {
                  locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString owc-config.port}";
                    extraConfig = ''
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $scheme;
                    '';
                  };
                  locations."/static/" = {
                    alias = "${owc-config.package}/static/";
                  };
                  locations."/media/" = {
                    alias = "${./.}/media/";
                  };
                }
                owc-config.nginx.extraConfig
              ];
            };
          };
        };
      };
    };
}
