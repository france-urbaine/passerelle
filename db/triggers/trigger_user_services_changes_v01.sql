CREATE TRIGGER trigger_user_services_changes
AFTER INSERT OR DELETE ON user_services
FOR EACH ROW EXECUTE FUNCTION trigger_user_services_changes();