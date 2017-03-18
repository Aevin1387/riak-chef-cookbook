#
# Author:: Benjamin Black (<b@b3k.us>) and Sean Cribbs (<sean@basho.com>)
# Cookbook Name:: riak
#
# Copyright (c) 2014 Basho Technologies, Inc.
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
default['riak']['package']['enterprise_key'] = ''

default['riak']['package']['version']['major'] = '2'
default['riak']['package']['version']['minor'] = '2'
default['riak']['package']['version']['incremental'] = '1'
default['riak']['package']['version']['build'] = '1'
default['riak']['package']['local']['url'] = ''

default['riak']['package']['local']['checksum'].tap do |checksum|
  checksum['ubuntu']['16']   = '7d5427fe68ac0688939dd49e7d1727fa9ae5f21f5b5936fafb202fef6b3f1837'
  checksum['ubuntu']['14']   = '98219e26cfe4ad59a21be9fb9af70dd41ff6a7088717cee7b7895b3f0390620d'
  checksum['ubuntu']['12']   = '8fd17a178378c5b2f549a4bcf1a6ddc5b91bdb57c6820184e19b71990e27b429'
  checksum['debian']['8']    = '1b1d3b2c0ba5b3e78de50b104af2c675e14036c284fcebb827ec19c8ba68d983'
  checksum['debian']['7']    = '7f162e45c3b4c840e6748802101b8859185c2740316cc77aa3525d059f756f82'
  checksum['centos']['7']    = 'dba898731cd5aaaf79e20f967ff7571aac0f0d4c7f512b87c489917608578f22'
  checksum['centos']['6']    = '3f58ae4d72b206fc9c073cf7dfbdc4099ea6541aa21e66d315460c779abe93d7'
  checksum['freebsd']['10']  = '1d1b2572e146a6d99d23e514781fb9799e43080075bda2484e645428f3835129'
  checksum['amazon']['2014'] = checksum['centos']['6']
end

default['riak']['package']['enterprise']['checksum'].tap do |checksum|
  checksum['ubuntu']['16']   = '2b28aeabb21488125b7e39f768c8f3b98ac816d1a30c0d618c9f82f99e6e89d9'
  checksum['ubuntu']['14']   = '0f37783ae2426d60187f24c9edcbf2322db38ff232a7e6b29ca89699ed3c8345'
  checksum['ubuntu']['12']   = '072dec713ad1a4f9f5aa7f76f414b02b5f8cbac769fb497c918f2f19cd88c6c3'
  checksum['debian']['7']    = '6d7da002dafef53f0c8b6b2f45de68629ad0efbd5a67f167bd56fbdc7467664a'
  checksum['centos']['7']    = '52ac620e311caff1d857e705ce717f93d8e53e9fd7d8a29c190007cfed79351c'
  checksum['centos']['6']    = '56266a8ced423f3cb53abd06112fe18a9ecb440c86b98d3de9266198e8283bdc'
  checksum['freebsd']['10']  = 'df8312ef6ce4c8f0531d4c7a7ff1a6f03852702853955b24989fe1494e979c87'
  checksum['amazon']['2014'] = checksum['centos']['6']
end
