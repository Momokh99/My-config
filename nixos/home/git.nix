{
  programs.git = {
    enable = true;
    settings = {
        user = {
            name = "Momokh99";
            email = "mohamedkhamekhami@gmail.com";
    };
        init = {defaultBranch = "main";
        };
        pull = {rebase = true;
        };
        };
    };

  programs.gh={
    enable = true;
    gitCredentialHelper.enable = true;
    };
}
