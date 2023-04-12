CREATE TRIGGER trigger_offices_changes
  AFTER INSERT OR UPDATE OR DELETE ON offices
  FOR EACH ROW EXECUTE FUNCTION trigger_offices_changes();