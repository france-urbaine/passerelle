CREATE TRIGGER trigger_service_communes_changes
AFTER INSERT OR DELETE ON service_communes
FOR EACH ROW EXECUTE FUNCTION trigger_service_communes_changes();