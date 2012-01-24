require 'rubygems'
require 'serialport'
require 'test/unit'


class TestSerialPort < Test::Unit::TestCase #:nodoc:

  def setup
    return unless @device.nil?
    if File::directory?("/dev")
      # POSIX
      # Currently only searches for USB<->Serial cables
      Dir.foreach("/dev") do |device|
        if device.index("ttyUSB")
          @device = "/dev/" + device
          break
        elsif device.index("cu.usbserial")
          @device = "/dev/" + device
          break
        end
      end
    else
      # Windows
      (1..9).each do |port|
        begin
          sp = SerialPort.new("COM#{port}")
          sp.close
          @device = "COM#{port}"
        rescue Errno::ENOENT
          # Not a valid serial port
        end
      end
    end

    if @device.nil?
      abort "Could not find serial port"
    end
  end

  def teardown
    begin
      @sp.close
    rescue Exception => e
      # Nothing to close
    end
  end

  def test_default_new
    assert_raise(ArgumentError) { SerialPort.new() }
    assert_nothing_raised(Exception) { @sp = SerialPort.new(@device) }
    assert_instance_of(SerialPort, @sp)
    assert_nothing_raised(Exception) { @sp.close }
  end

  def test_params_hash
    @sp = SerialPort.new(@device)
    assert_nothing_raised(Exception) { @params = @sp.get_modem_params() }
    assert_instance_of(Hash, @params)
    assert(@params.has_key?('baud'))
    assert(@params.has_key?('data_bits'))
    assert(@params.has_key?('stop_bits'))
    assert(@params.has_key?('parity'))
    assert(@params.has_key?('flow_control'))
    assert(@params.has_key?('read_timeout'))
  end

  def test_new_with_hash_params
    params = {
      "baud"         => 19200,
      "data_bits"    => 7,
      "stop_bits"    => 2,
      "parity"       => SerialPort::EVEN,
      "flow_control" => SerialPort::SOFT,
      "read_timeout" => 100
    }
    assert_nothing_raised(Exception) { @sp = SerialPort.new(@device, params) }
    assert_instance_of(SerialPort, @sp)
    assert_nothing_raised(Exception) { @actual = @sp.get_modem_params }
    assert_instance_of(Hash, @actual)
    assert_equal(params['baud'], @actual['baud'])
    assert_equal(params['data_bits'], @actual['data_bits'])
    assert_equal(params['stop_bits'], @actual['stop_bits'])
    assert_equal(params['parity'], @actual['parity'])
    assert_equal(params['flow_control'], @actual['flow_control'])
    assert_equal(params['read_timeout'], @actual['read_timeout'])
  end

  def test_open
    assert_nothing_raised(Exception) {
      @sp = SerialPort.open(@device) {
        
      }
    }
  end

  def test_standard_baud
    @sp = SerialPort.new(@device, {"baud" => 19200})
    assert_equal(19200, @sp.baud)
    assert_nothing_raised(Exception) { @sp.baud = 38400 }
    assert_equal(38400, @sp.baud)
  end

  def test_custom_baud
    params = {
      "baud"         => 19200,
      "data_bits"    => 7,
      "stop_bits"    => 2,
      "parity"       => SerialPort::EVEN,
      "flow_control" => SerialPort::SOFT,
      "read_timeout" => 100
    }
    @sp = SerialPort.new(@device, params)
    assert_nothing_raised(Exception) { @sp.baud = 15625 }
    assert_nothing_raised(Exception) { @baud = @sp.baud }
    assert_equal(15625, @sp.baud)
    actual = @sp.get_modem_params
    assert_equal(params['data_bits'], actual['data_bits'])
    assert_equal(params['stop_bits'], actual['stop_bits'])
    assert_equal(params['parity'], actual['parity'])
    assert_equal(params['flow_control'], actual['flow_control'])
    assert_equal(params['read_timeout'], actual['read_timeout'])
  end

  def test_invalid_baud
    @sp = SerialPort.new(@device)
    initial_baud = @sp.baud
    assert_raise(ArgumentError) { @sp.baud = 0 }
    assert_raise(ArgumentError) { @sp.baud = 100000000 }
    assert_equal(initial_baud, @sp.baud)
  end

  def test_data_bits
    @sp = SerialPort.new(@device)
    assert_nothing_raised(Exception) { @sp.data_bits }
    assert_nothing_raised(Exception) { @sp.data_bits = 7 }
    assert_equal(7, @sp.data_bits)
    assert_raise(ArgumentError) { @sp.data_bits = 0 }
    assert_raise(ArgumentError) { @sp.data_bits = 9 }
    assert_equal(7, @sp.data_bits)
  end

  def test_flow_control
    @sp = SerialPort.new(@device)
    assert_nothing_raised(Exception) { @flow_control = @sp.flow_control }
    assert_nothing_raised(Exception) { @sp.flow_control = SerialPort::NONE }
    assert_nothing_raised(Exception) { @sp.flow_control = SerialPort::SOFT }
    assert_equal(SerialPort::SOFT, @sp.flow_control)
    assert_nothing_raised(Exception) { @sp.flow_control = SerialPort::HARD }
    assert_equal(SerialPort::HARD, @sp.flow_control)
    assert_nothing_raised(Exception) { @sp.flow_control = SerialPort::SOFT | SerialPort::HARD }
    assert_equal(SerialPort::SOFT | SerialPort::HARD, @sp.flow_control)
    assert_nothing_raised(Exception) { @sp.flow_control = SerialPort::NONE }
    assert_equal(SerialPort::NONE, @sp.flow_control)
    assert_raise(ArgumentError) { @sp.flow_control = -1 }
    assert_equal(SerialPort::NONE, @sp.flow_control)
  end

  def test_modem_params
    params = {
      "baud"         => 19200,
      "data_bits"    => 7,
      "stop_bits"    => 2,
      "parity"       => SerialPort::EVEN,
      "flow_control" => SerialPort::SOFT,
      "read_timeout" => 100
    }
    @sp = SerialPort.new(@device)
    assert_nothing_raised(Exception) { @sp.modem_params = params }
    assert_nothing_raised(Exception) { @actual = @sp.modem_params }
    assert_instance_of(Hash, @actual)
    assert_equal(params['baud'], @actual['baud'])
    assert_equal(params['data_bits'], @actual['data_bits'])
    assert_equal(params['stop_bits'], @actual['stop_bits'])
    assert_equal(params['parity'], @actual['parity'])
    assert_equal(params['flow_control'], @actual['flow_control'])
    assert_equal(params['read_timeout'], @actual['read_timeout'])
  end

  def test_parity
    @sp = SerialPort.new(@device)
    assert_nothing_raised(Exception) { @sp.parity = SerialPort::NONE }
    assert_nothing_raised(Exception) { @sp.parity = SerialPort::EVEN }
    assert_equal(SerialPort::EVEN, @sp.parity)
    assert_nothing_raised(Exception) { @sp.parity = SerialPort::ODD }
    assert_equal(SerialPort::ODD, @sp.parity)
    assert_nothing_raised(Exception) { @sp.parity = SerialPort::NONE }
    assert_equal(SerialPort::NONE, @sp.parity)
    assert_raise(ArgumentError) { @sp.parity = -1 }
    assert_raise(ArgumentError) { @sp.parity = 100 }
    assert_raise(TypeError) { @sp.parity = 'not a number' }
    assert_equal(SerialPort::NONE, @sp.parity)
  end

  def test_read_timeout
    @sp = SerialPort.new(@device)
    assert_nothing_raised(Exception) { @sp.read_timeout = 0 }
    assert_equal(0 , @sp.read_timeout)
    assert_nothing_raised(Exception) { @sp.read_timeout = 100 }
    assert_equal(100, @sp.read_timeout)
    assert_nothing_raised(Exception) { @sp.read_timeout = -1 }
    assert_equal(-1, @sp.read_timeout)
    assert_nothing_raised(Exception) { @sp.read_timeout = 0 }
    assert_equal(0, @sp.read_timeout)
    assert_raise(TypeError) { @sp.read_timeout = 'not a number' }
  end

  def test_stop_bits
    @sp = SerialPort.new(@device)
    assert_nothing_raised(Exception) { @sp.stop_bits = 1 }
    assert_equal(1, @sp.stop_bits)
    assert_nothing_raised(Exception) { @sp.stop_bits = 2 }
    assert_equal(2, @sp.stop_bits)
    assert_nothing_raised(Exception) { @sp.stop_bits = 1 }
    assert_equal(1, @sp.stop_bits)
    assert_raise(ArgumentError) { @sp.stop_bits = 0 }
    assert_raise(ArgumentError) { @sp.stop_bits = 3 }
    assert_raise(TypeError) { @sp.stop_bits = 'not a number' }
    assert_equal(1, @sp.stop_bits)
  end

  def test_signals
    @sp = SerialPort.new(@device)
    # .dtr and .rts are not supported on Windows
    posix = (/mingw|mswin|cygwin|bccwin/ =~ RUBY_PLATFORM).nil?
    assert_nothing_raised(Exception) { @sp.cts }
    assert_kind_of(Numeric, @sp.cts)
    assert_nothing_raised(Exception) { @sp.dcd }
    assert_kind_of(Numeric, @sp.dcd)
    assert_nothing_raised(Exception) { @sp.dsr }
    assert_kind_of(Numeric, @sp.dsr)
    assert_nothing_raised(Exception) { @sp.dtr } if posix
    assert_nothing_raised(Exception) { @sp.dtr = 0 }
    assert_equal(0, @sp.dtr) if posix
    assert_nothing_raised(Exception) { @sp.dtr = 1 }
    assert_equal(1, @sp.dtr) if posix
    assert_nothing_raised(Exception) { @sp.ri }
    assert_kind_of(Numeric, @sp.ri)
    assert_nothing_raised(Exception) { @sp.rts } if posix
    assert_nothing_raised(Exception) { @sp.rts = 0 }
    assert_equal(0, @sp.rts) if posix
    assert_nothing_raised(Exception) { @sp.rts = 1 }
    assert_equal(1, @sp.rts) if posix
    assert_nothing_raised(Exception) { @signals = @sp.signals }
    assert_instance_of(Hash, @signals)
    assert_equal(@sp.cts, @signals['cts'])
    assert_equal(@sp.dcd, @signals['dcd'])
    assert_equal(@sp.dsr, @signals['dsr'])
    assert_equal(@sp.dtr, @signals['dtr']) if posix
    assert_equal(@sp.ri, @signals['ri'])
    assert_equal(@sp.rts, @signals['rts']) if posix
  end

end