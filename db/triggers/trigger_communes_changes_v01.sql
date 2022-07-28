CREATE TRIGGER trigger_communes_changes
AFTER INSERT OR UPDATE OR DELETE ON communes
FOR EACH ROW EXECUTE FUNCTION trigger_communes_changes();