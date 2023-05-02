CREATE TRIGGER trigger_ddfips_changes
  AFTER INSERT OR UPDATE OR DELETE ON ddfips
  FOR EACH ROW EXECUTE FUNCTION trigger_ddfips_changes();