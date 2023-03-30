resource "aws_cognito_user_pool" "harsh-viradia-user-pool" {
  name = "harsh-viradia-user-pool"
  auto_verified_attributes = [ "email" ]

  user_attribute_update_settings {
    attributes_require_verification_before_update = [ "email" ]
  }

  email_configuration {
    email_sending_account = "DEVELOPER"
    from_email_address = "harsh.viradia@intuitive.cloud"
    source_arn = "arn:aws:ses:us-east-1:587172484624:identity/harsh.viradia@intuitive.cloud"
  }

  account_recovery_setting {
    recovery_mechanism {
      name = "verified_email"
      priority = 1
    }
  }

}

resource "aws_cognito_user_pool_client" "harsh-viradia-client" {
  name = "harsh-viradia-client"
  user_pool_id = aws_cognito_user_pool.harsh-viradia-user-pool.id
}