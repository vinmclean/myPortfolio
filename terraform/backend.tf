terraform {
  cloud {
    organization = "vinmclean42"

    workspaces {
      name = "myPortfolio-infra-main"
    }
  }
}