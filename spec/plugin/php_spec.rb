require 'spec_helper'

describe "php" do
  let(:filename) { 'test.php' }

  specify "echo" do
    set_file_contents '<?php "Text" ?>'

    vim.switch
    assert_file_contents '<?php echo "Text" ?>'

    vim.switch
    assert_file_contents '<?php "Text" ?>'
  end
end
