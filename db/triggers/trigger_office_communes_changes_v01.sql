CREATE TRIGGER trigger_office_communes_changes
  AFTER INSERT OR DELETE ON office_communes
  FOR EACH ROW EXECUTE FUNCTION trigger_office_communes_changes();