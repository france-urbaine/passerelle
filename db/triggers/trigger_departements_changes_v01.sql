CREATE TRIGGER trigger_departements_changes
  AFTER INSERT OR UPDATE OR DELETE ON departements
  FOR EACH ROW EXECUTE FUNCTION trigger_departements_changes();