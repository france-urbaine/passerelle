CREATE TRIGGER trigger_epcis_changes
  AFTER INSERT OR UPDATE OR DELETE ON epcis
  FOR EACH ROW EXECUTE FUNCTION trigger_epcis_changes();