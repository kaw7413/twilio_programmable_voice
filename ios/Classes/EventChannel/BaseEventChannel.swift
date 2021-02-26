import Foundation
import Flutter

public class BaseEventChannel: NSObject, FlutterStreamHandler {
	private enum NilEventSinkError: Error {
			case runtimeError(String)
	}
	
	public let eventChannel: FlutterEventChannel;
	public var eventSink: FlutterEventSink?;
	public var queue: [Any] = [];
	
	init(eventChannel: FlutterEventChannel) {
		print("[BaseEventHandler]", "constructor called");
		self.eventChannel = eventChannel;
		
		// use because we can't use self to delegate directly
		super.init();
		
		self.eventChannel.setStreamHandler(self);
	}
	
	public func send(data: Any) {
		print("[BaseEventHandler]", "send called");
		
		if (eventSink == nil) {
			print("[BaseEventHandler]", "add data to queue");
			queue.append(data);
		} else {
			print("[BaseEventHandler]", "send data throught eventSink");
			eventSink!(data);
		}
	}
	
	public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
		print("[BaseEventHandler]", "onListen called");
		self.eventSink = events;
		
		do {
			try deQueue();
		} catch NilEventSinkError.runtimeError(let errorMessage){
			print(errorMessage);
		} catch {
			print("Unknow error")
		}
		
		return nil;
	}
	
	public func onCancel(withArguments arguments: Any?) -> FlutterError? {
		self.eventSink = nil;
		return nil
	}
	
	private func deQueue() throws {
		print("[BaseEventHandler]", "deQueue called");
		if(self.eventSink == nil) {
			throw NilEventSinkError.runtimeError("Event Sink is nil");
		} else {
			self.queue.forEach { (data) in
				self.eventSink!(data);
			}
		}
	}
}
