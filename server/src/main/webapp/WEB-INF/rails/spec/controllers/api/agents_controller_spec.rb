#
# Copyright 2019 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rails_helper'

describe Api::AgentsController do
  before do
    allow(controller).to receive(:agent_service).and_return(@agent_service = double('agent-service'))
    allow(controller).to receive(:job_instance_service).and_return(@job_instance_service = double('job instance service'))
    login_as_user
    login_as_admin
  end

  describe "job_run_history" do
    include APIModelMother

    it "should add deprecation API headers" do
      expect(@job_instance_service).to receive(:totalCompletedJobsCountOn).with('uuid').and_return(10)
      expect(@job_instance_service).to receive(:completedJobsOnAgent).with('uuid', anything, anything, anything).and_return(create_agent_job_run_history_model)

      get :job_run_history, params:{:uuid => 'uuid', :offset => '5', :no_layout => true}

      expect(response).to be_ok
      expect(response.headers["X-GoCD-API-Deprecated-In"]).to eq('v19.12.0')
      expect(response.headers["X-GoCD-API-Removal-In"]).to eq('v20.3.0')
      expect(response.headers["X-GoCD-API-Deprecation-Info"]).to eq("https://api.gocd.org/19.12.0/#api-changelog")
      expect(response.headers["Link"]).to eq('<http://test.host/api/agents/uuid/job_run_history/5>; Accept="application/vnd.go.cd.v1+json"; rel="successor-version"')
      expect(response.headers["Warning"]).to eq('299 GoCD/v19.12.0 "The Agent Job Run History unversioned API has been deprecated in GoCD Release v19.12.0. This version will be removed in GoCD Release v20.3.0. Version v1 of the API is available, and users are encouraged to use it"')
    end


    it "should resolve routes" do
      expect(:get => "/api/agents/1234/job_run_history").to route_to({:controller => 'api/agents', :action => 'job_run_history', :uuid => '1234', :offset => '0', :no_layout => true})
      expect(:get => "/api/agents/1234/job_run_history/1").to route_to({:controller => 'api/agents', :action => 'job_run_history', :uuid => '1234', :offset => '1', :no_layout => true})
    end

    it "should render job run history json" do
      expect(@job_instance_service).to receive(:totalCompletedJobsCountOn).with('uuid').and_return(10)
      expect(@job_instance_service).to receive(:completedJobsOnAgent).with('uuid', anything, anything, anything).and_return(create_agent_job_run_history_model)

      get :job_run_history, params:{:uuid => 'uuid', :offset => '5', :no_layout => true}

      expect(response.body).to eq(AgentJobRunHistoryAPIModel.new(Pagination.pageStartingAt(5, 10, 10), create_agent_job_run_history_model).to_json)
    end
  end
end
