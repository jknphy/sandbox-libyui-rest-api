require_relative '../add_host.rb'
 
describe HostConfiguration do
	context "When module is open" do
		it "is displayed a heading title 'Host Configuration" do
			hc = HostConfiguration.new
			label = hc.read_module_heading
			expect(label).to eq "Host Configuration"
		end
	end
	context "When button Add is clicked" do	
		it "appears a pop-up" do
			hc = HostConfiguration.new
			hc.click_button_add
			hc.check_add_dialog_loaded
		end
	end
	context "When dialog is filled in and click ok" do	
		it "appears a new row in the table with corresponding data" do
			hc = HostConfiguration.new
			hc.fill_hostname_form
			hc.confirm_dialog
			hc.wait
			expect(hc.check_new_row_added).to be true
		end
	end
	context "When confirm changes in YaST module" do
		it "should be added new hostname to /etc/hosts" do
			hc = HostConfiguration.new
			hc.confirm_changes
			hc.wait
			expect(hc.check_configuration_file).to be true
		end
	end
end

