resource "aws_cognito_user_pool" "api_user_pool" {

  name = "api-user-pool"

}

resource "aws_cognito_user_pool_client" "client" {

  name = "client"

  allowed_oauth_flows_user_pool_client = true

  generate_secret = false

  allowed_oauth_scopes = ["aws.cognito.signin.user.admin","email", "openid", "profile"]

  allowed_oauth_flows = ["implicit", "code"]

  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]

  supported_identity_providers = ["COGNITO"]



  user_pool_id = aws_cognito_user_pool.pool.id

}

resource "aws_cognito_user" "api_user" {

  user_pool_id = aws_cognito_user_pool.pool.id

  username = "aws-gateway"

  password = "Test@123"

}