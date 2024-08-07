require "rails_helper"

RSpec.describe AgentConnect::AuthController, type: :controller do
  routes { AgentConnect::Engine.routes }

  before {
    WebMock.disable_net_connect!
  }

  describe "#auth" do
    it "redirects to AgentConnect" do
      get :auth
      expect(response).to redirect_to(start_with("https://fca.integ01.dev-agentconnect.fr/api/v2/authorize?"))

      redirect_url = response.headers["Location"]
      redirect_url_query_params = Rack::Utils.parse_query(URI.parse(redirect_url).query)

      expect(redirect_url_query_params.symbolize_keys).to match(
        acr_values: "eidas1",
        client_id: "client_id",
        redirect_uri: "http://test.host/agent_connect/callback",
        response_type: "code",
        scope: "openid email given_name usual_name",
        state: be_a_kind_of(String),
        nonce: be_a_kind_of(String)
      )
    end
  end

  describe "#callback" do
    let(:state) { AgentConnect::Client::Auth.new.state }
    let(:code) { "IDej8hpYou2rZLsDgTzZ_nMl1aXmNajpByd20dig4e8" }

    let(:user_info) do
      {
        "sub" => "ab70770d-1285-46e6-b4d0-3601b49698d4",
        "email" => "francis.factice@exemple.gouv.fr",
        "given_name" => "Francis Factice",
        "usual_name" => "Factice",
        "aud" => "4ec41582-1d60-4f12-a63b-d8abaace16ba",
        "exp" => 1717595030, "iat" => 1717594970, "iss" => "https://fca.integ01.dev-agentconnect.fr/api/v2",
      }
    end

    before do
      session[:agent_connect_state] = state
      AgentConnectStubs.stub_callback_requests(code, user_info)
    end

    it "calls the success callback" do
      expect(AgentConnect).to receive(:success_callback).once.and_call_original
      get :callback, params: { state: state, code: code }
      expect(response).to redirect_to("/success_path")
      expect(session[:agent][:email]).to eq("francis.factice@exemple.gouv.fr")
      expect(session[:agent][:first_name]).to eq("Francis")
      expect(session[:agent][:last_name]).to eq("Factice")
    end

    context "when an error occurs" do
      before do
        allow(OpenIDConnect::ResponseObject::IdToken).to receive(:decode).and_raise(OpenIDConnect::ResponseObject::IdToken::InvalidToken)
      end

      it "calls the error callback" do
        expect(AgentConnect).to receive(:error_callback).once.and_call_original
        get :callback, params: { state: state, code: code }
        expect(response).to redirect_to("/error_path")
      end
    end
  end
end
