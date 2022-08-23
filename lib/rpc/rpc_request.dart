/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:convert';
import '../src/models/serialisable.dart';
import '../types/method.dart';


/// RPC Request
/// ------------------------------------------------------------------------------------------------

class RpcRequest extends Serialisable {
  
  /// Creates a JSON-RPC request to invoke [method] with [params].
  /// 
  /// ```
  /// {
  ///   'jsonrpc': '2.0',
  ///   'id': [id],
  ///   'method': [method],
  ///   'params': [params],
  /// }
  /// ```
  const RpcRequest(
    this.method, {
    this.params, 
    this.id,
  }): assert(id == null || id >= 0);

  /// The default JSON-RPC protocol version.
  static const String version = '2.0';

  /// The JSON-RPC protocol version.
  final String jsonrpc = version;

  /// The method to be invoked.
  final Method method;

  /// A JSON array of ordered parameter values.
  final List<Object>? params;
  
  /// A unique client-generated identifier.
  final int? id;

  /// Generates a hash that uniquely identifies this request's method invocation.
  /// 
  /// The [hash] is derived by JSON encoding the request's [method] and [params]. Two [RpcRequest]s 
  /// will produce the same hash if they contain the same [method] and `ordered` [params].
  /// 
  /// ```
  /// final p0 = ['Gr54...5Fd5', { 'encoding': 'base64', 'commitment': 'finalized' }];
  /// final r0 = RpcRequest(Method.getAccountInfo, params: p0, id: 0);
  /// 
  /// final p1 = ['Gr54...5Fd5', { 'encoding': 'base64', 'commitment': 'finalized' }];
  /// final r1 = RpcRequest(Method.getAccountInfo, params: p1, id: 1);
  /// 
  /// final p2 = ['Gr54...5Fd5', { 'commitment': 'finalized', 'encoding': 'base64' }];
  /// final r2 = RpcRequest(Method.getAccountInfo, params: p2, id: 1);
  /// 
  /// assert(r0.hash() == r1.hash()); // true
  /// assert(r1.hash() == r2.hash()); // false, the configuration values are ordered differently.
  /// 
  /// TODO: Sort by keys, then hash.
  /// ```
  String hash() => json.encode([method.name, params]);

  /// Creates a JSON [RpcRequest] to invoke a [method].
  /// 
  /// The [method]'s parameters are passed using the [params] list and [config] object.
  /// 
  /// ```
  /// RpcRequest.build(                                   // {
  ///   Method.getAccountInfo,                            //   'jsonrpc': '2.0',
  ///   [                                                 //   'id': 1,
  ///     '3C4iYswhNe7Z2LJvxc9qQmF55rsKDUGdiuKVUGpTbRsK', //   'method': 'getAccountInfo',
  ///   ],                                                //   'params': [
  ///   GetAccountInfoConfig(                             //     '3C4iYswh...UGpTbRsK',
  ///     id: 1,                                          //     {
  ///     encoding: AccountEncoding.base64,               //       'encoding': 'base64',
  ///   ),                                                //     },
  /// );                                                  //   ],
  ///                                                     // }
  /// ```
  // factory RpcRequest.build(
  //   final Method method,
  //   final List<Object> params, 
  //   final RpcRequestConfig config,
  // ) {
  //   final Map<String, dynamic> object = config.object();
  //   final List<Object>? parameters = object.isEmpty ? params : params..add(object);
  //   return RpcRequest._(method, params: parameters, id: config.id);
  // }

  /// Creates a copy of `this` instance, applying the provided parameters to the new instance.
  /// 
  /// ```
  /// const RpcRequest request = RpcRequest(
  ///   Method.getAccountInfo, 
  ///   params: ['4fGh...GTh6'],
  ///   id: 0,
  /// );
  /// final RpcRequest newRequest = request.copyWith(id: 1);
  /// print(newRequest.toJson()); // { 
  ///                             //    'jsonrpc': '2.0', 
  ///                             //    'method': 'getAccountInfo', 
  ///                             //    'params': ['4fGh...GTh6'], 
  ///                             //    'id': 1, 
  ///                             // }
  /// ```
  RpcRequest copyWith({
    Method? method,
    List<Object>? params,
    int? id,
  }) => RpcRequest(
    method ?? this.method,
    params: params ?? this.params,
    id: id ?? this.id,
  );

  @override
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'method': method.name,
    'params': params,
    'id': id,
  };
}