module StatusTestHelpers
  def assert_status(child, fy, statuses)
    status = child.status(fy)
    statuses.each_pair do |k, v|
      assert_equal v, status.send(k), "#{k} failed"
    end
  end
end
