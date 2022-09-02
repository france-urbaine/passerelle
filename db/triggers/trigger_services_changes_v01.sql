CREATE TRIGGER trigger_services_changes
AFTER INSERT OR UPDATE OR DELETE ON services
FOR EACH ROW EXECUTE FUNCTION trigger_services_changes();