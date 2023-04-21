require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class AmazonSpApi < OmniAuth::Strategies::OAuth2
      attr_reader :selling_partner_id, :mws_auth_token, :state

      option :name, 'amazon_sp_api'

      option :client_options,
             {
               site: 'https://sellingpartnerapi-na.amazon.com',
               authorize_url: 'https://sellercentral.amazon.com/apps/authorize/consent',
               token_url: 'https://api.amazon.com/auth/o2/token'
             }

      extra do
        {
          'selling_partner_id' => selling_partner_id,
          'mws_auth_token' => mws_auth_token,
          'state' => state
        }
      end

      def callback_phase
        @selling_partner_id = request.params['selling_partner_id']
        @mws_auth_token = request.params['mws_auth_token']
        @state = request.params['state']
        super
      end

      def build_access_token
        verifier = request.params['spapi_oauth_code']
        client.auth_code.get_token(
          verifier,
          { redirect_uri: callback_url }.merge(
            token_params.to_hash(symbolize_keys: true)
          ),
          deep_symbolize(options.auth_token_params)
        )
      end

      def callback_url
        options[:redirect_uri] || full_host + script_name + callback_path
      end
    end
  end
end
