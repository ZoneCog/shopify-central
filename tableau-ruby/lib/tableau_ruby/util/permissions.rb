module Tableau
  module Util
    module Permissions
      def build_permissions_for_user(xml, params)
        xml.granteeCapabilities do
          xml.user(id: params[:user_id])
          xml.capabilities do
            params[:permissions][:allow].each { |c| xml.capability(name: c, mode: 'Allow') }
            params[:permissions][:deny].each  { |c| xml.capability(name: c, mode: 'Deny') }
          end
        end
      end

      def build_permissions_for_group(xml, params)
        xml.granteeCapabilities do
          xml.group(id: params[:group_id])
          xml.capabilities do
            params[:permissions][:allow].each { |c| xml.capability(name: c, mode: 'Allow') }
            params[:permissions][:deny].each  { |c| xml.capability(name: c, mode: 'Deny') }
          end
        end
      end
    end
  end
end